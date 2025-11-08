import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/api.dart' show ParametersWithRandom;
import 'package:asn1lib/asn1lib.dart' as asn1;

class RSAEncryption {
  static const String _publicKeyKey = 'rsa_public_key';
  static const String _privateKeyKey = 'rsa_private_key';

  // Generate RSA key pair
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      _generateKeyPair() async {
    final keyGen = RSAKeyGenerator();
    final secureRandom = FortunaRandom();

    // Initialize random seed
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(crypto.KeyParameter(Uint8List.fromList(seeds)));

    final keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
    final parametersWithRandom =
        ParametersWithRandom(keyParams, secureRandom);
    keyGen.init(parametersWithRandom);

    return keyGen.generateKeyPair();
  }

  // Convert RSAPublicKey to PEM format
  String _publicKeyToPem(dynamic publicKey) {
    // Access modulus and exponent from the public key
    // The key from pointycastle has these properties
    final modulus = (publicKey as dynamic).modulus!;
    final exponent = (publicKey as dynamic).exponent!;
    
    final algorithmSeq = asn1.ASN1Sequence();
    final algorithmAsn1Obj = asn1.ASN1Object.fromBytes(Uint8List.fromList([
      0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01,
      0x01, 0x05, 0x00
    ]));
    algorithmSeq.add(algorithmAsn1Obj);

    final publicKeySeq = asn1.ASN1Sequence();
    publicKeySeq.add(asn1.ASN1Integer(modulus));
    publicKeySeq.add(asn1.ASN1Integer(exponent));
    final publicKeySeqBitString = asn1.ASN1BitString(publicKeySeq.encodedBytes);

    final topLevelSeq = asn1.ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);

    final dataBase64 = base64Encode(topLevelSeq.encodedBytes);
    return '-----BEGIN PUBLIC KEY-----\n$dataBase64\n-----END PUBLIC KEY-----';
  }

  // Convert RSAPrivateKey to PEM format
  String _privateKeyToPem(dynamic privateKey) {
    // Access private key properties
    final n = (privateKey as dynamic).n!;
    final exponent = (privateKey as dynamic).exponent!;
    final d = (privateKey as dynamic).d!;
    final p = (privateKey as dynamic).p!;
    final q = (privateKey as dynamic).q!;
    
    final version = asn1.ASN1Integer(BigInt.from(0));
    final modulus = asn1.ASN1Integer(n);
    final publicExponent = asn1.ASN1Integer(exponent);
    final privateExponent = asn1.ASN1Integer(d);
    final pInt = asn1.ASN1Integer(p);
    final qInt = asn1.ASN1Integer(q);
    final dP = asn1.ASN1Integer((d % (p - BigInt.one)));
    final dQ = asn1.ASN1Integer((d % (q - BigInt.one)));
    final qInv = asn1.ASN1Integer(q.modInverse(p));

    final seq = asn1.ASN1Sequence();
    seq.add(version);
    seq.add(modulus);
    seq.add(publicExponent);
    seq.add(privateExponent);
    seq.add(pInt);
    seq.add(qInt);
    seq.add(dP);
    seq.add(dQ);
    seq.add(qInv);

    final dataBase64 = base64Encode(seq.encodedBytes);
    return '-----BEGIN RSA PRIVATE KEY-----\n$dataBase64\n-----END RSA PRIVATE KEY-----';
  }

  // Get or generate public key
  Future<dynamic> _getPublicKey() async {
    final prefs = await SharedPreferences.getInstance();
    final publicKeyPem = prefs.getString(_publicKeyKey);

    if (publicKeyPem != null) {
      final parser = RSAKeyParser();
      return parser.parse(publicKeyPem);
    } else {
      // Generate new keys
      final keyPair = await _generateKeyPair();
      final publicKey = keyPair.publicKey;
      final privateKey = keyPair.privateKey;

      // Convert to PEM format
      final publicKeyPemStr = _publicKeyToPem(publicKey);
      final privateKeyPemStr = _privateKeyToPem(privateKey);
      
      // Save keys
      await prefs.setString(_publicKeyKey, publicKeyPemStr);
      await prefs.setString(_privateKeyKey, privateKeyPemStr);

      // Parse and return the public key using encrypt package
      final parser = RSAKeyParser();
      return parser.parse(publicKeyPemStr);
    }
  }

  // Get or generate private key
  Future<dynamic> _getPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKeyPem = prefs.getString(_privateKeyKey);

    if (privateKeyPem != null) {
      final parser = RSAKeyParser();
      return parser.parse(privateKeyPem);
    } else {
      // Generate new keys
      final keyPair = await _generateKeyPair();
      final publicKey = keyPair.publicKey;
      final privateKey = keyPair.privateKey;

      // Convert to PEM format
      final publicKeyPemStr = _publicKeyToPem(publicKey);
      final privateKeyPemStr = _privateKeyToPem(privateKey);
      
      // Save keys
      await prefs.setString(_publicKeyKey, publicKeyPemStr);
      await prefs.setString(_privateKeyKey, privateKeyPemStr);

      // Parse and return the private key using encrypt package
      final parser = RSAKeyParser();
      return parser.parse(privateKeyPemStr);
    }
  }

  // Encrypt data using RSA public key
  Future<String> encrypt(String plainText) async {
    try {
      final publicKey = await _getPublicKey();
      final encrypter = Encrypter(
        RSA(
          publicKey: publicKey,
          encoding: RSAEncoding.OAEP,
        ),
      );

      final encrypted = encrypter.encrypt(plainText);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt data using RSA private key
  Future<String> decrypt(String encryptedText) async {
    try {
      final privateKey = await _getPrivateKey();
      final encrypter = Encrypter(
        RSA(
          privateKey: privateKey,
          encoding: RSAEncoding.OAEP,
        ),
      );

      final encrypted = Encrypted.fromBase64(encryptedText);
      return encrypter.decrypt(encrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Encrypt large text by chunking (RSA has size limitations)
  Future<String> encryptLargeText(String plainText) async {
    try {
      // RSA with 2048-bit key can encrypt up to ~245 bytes with OAEP
      // We'll use 200 bytes per chunk to be safe
      const chunkSize = 200;
      final chunks = <String>[];

      final bytes = utf8.encode(plainText);
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = utf8.decode(bytes.sublist(i, end));
        final encryptedChunk = await encrypt(chunk);
        chunks.add(encryptedChunk);
      }

      // Store chunks as JSON array encoded in base64
      return base64Encode(utf8.encode(jsonEncode(chunks)));
    } catch (e) {
      throw Exception('Large text encryption failed: $e');
    }
  }

  // Decrypt large text by de-chunking
  Future<String> decryptLargeText(String encryptedText) async {
    try {
      // Decode the base64 JSON array
      final chunksData = utf8.decode(base64Decode(encryptedText));
      final chunks = List<String>.from(jsonDecode(chunksData));

      final decryptedChunks = <String>[];
      for (final chunk in chunks) {
        final decryptedChunk = await decrypt(chunk);
        decryptedChunks.add(decryptedChunk);
      }

      return decryptedChunks.join('');
    } catch (e) {
      throw Exception('Large text decryption failed: $e');
    }
  }
}

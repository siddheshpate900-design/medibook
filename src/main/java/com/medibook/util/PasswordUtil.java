package com.medibook.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Password storage.
 *
 * Passwords are never stored in plain text. Each password is hashed with
 * PBKDF2 (HMAC-SHA256, 60000 rounds) together with a random 16 byte salt,
 * so two users with the same password get different strings in the table.
 *
 * Stored format:  pbkdf2_sha256$rounds$salt$hash
 */
public final class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ROUNDS = 60000;
    private static final int KEY_LENGTH = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    public static String hash(String plainPassword) {
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        String saltPart = Base64.getEncoder().encodeToString(salt);
        String hashPart = Base64.getEncoder().encodeToString(derive(plainPassword, salt));
        return "pbkdf2_sha256$" + ROUNDS + "$" + saltPart + "$" + hashPart;
    }

    public static boolean matches(String plainPassword, String storedValue) {
        if (plainPassword == null || storedValue == null) {
            return false;
        }
        String[] parts = storedValue.split("\\$");
        if (parts.length != 4) {
            return false;
        }
        try {
            int rounds = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            byte[] actual = derive(plainPassword, salt, rounds, expected.length * 8);
            return MessageDigest.isEqual(expected, actual);
        } catch (RuntimeException e) {
            return false;
        }
    }

    private static byte[] derive(String password, byte[] salt) {
        return derive(password, salt, ROUNDS, KEY_LENGTH);
    }

    private static byte[] derive(String password, byte[] salt, int rounds, int keyLength) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, rounds, keyLength);
            return SecretKeyFactory.getInstance(ALGORITHM).generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("Password hashing failed: " + e.getMessage(), e);
        }
    }

    /** Used by the SQL loader and the tests, not by the running application. */
    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("usage: PasswordUtil <password>");
            return;
        }
        System.out.println(hash(args[0]));
    }
}

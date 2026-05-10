package org.sid.security;

public class SecurityConstants {
    public static final String SECRET = "9faa372517ac1d389758d8a186d6d2f9c3fdb4e7e51d5a3b8c2a1e6f4d7b0c5e";
    public static final long EXPIRATION_TIME = 864_000_000; // 10 jours
    public static final String TOKEN_PREFIX = "Bearer ";
    public static final String HEADER_STRING = "Authorization";
    public static final String LOGIN_URL = "/auth/login";
}

package org.sid.ebankingbackend.security;

import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Charge les utilisateurs pour Spring Security.
 * TODO : Remplace les utilisateurs en dur par une vraie recherche en base (CustomerRepository, etc.)
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final PasswordEncoder passwordEncoder;

    public UserDetailsServiceImpl(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // ─── Utilisateurs de test ───────────────────────────────────────────────
        // Remplace cette section par : return customerRepository.findByUsername(username)...
        switch (username) {
            case "admin":
                return User.builder()
                        .username("admin")
                        .password(passwordEncoder.encode("1234"))
                        .roles("USER", "ADMIN")
                        .build();
            case "user1":
                return User.builder()
                        .username("user1")
                        .password(passwordEncoder.encode("1234"))
                        .roles("USER")
                        .build();
            default:
                throw new UsernameNotFoundException("Utilisateur introuvable : " + username);
        }
    }
}

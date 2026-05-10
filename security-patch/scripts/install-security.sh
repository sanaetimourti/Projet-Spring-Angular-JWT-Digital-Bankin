#!/usr/bin/env bash
# ============================================================
#  install-security.sh
#  Script d'installation de la couche sécurité JWT
#  Projet: Digital Banking - Prof. Mohamed Youssfi
# ============================================================

set -e

# ── Couleurs ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   🔐 Installation Couche Sécurité JWT            ║"
echo "║   Spring Security + JWT — Digital Banking        ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Détection du package principal ──────────────────────────
echo -e "${YELLOW}🔍 Détection du package Java...${NC}"

MAIN_CLASS=$(find src/main/java -name "*.java" | xargs grep -l "@SpringBootApplication" 2>/dev/null | head -1)

if [ -z "$MAIN_CLASS" ]; then
    echo -e "${RED}❌ Impossible de trouver la classe principale. Es-tu dans la racine du projet ?${NC}"
    exit 1
fi

# Extrait le nom de package depuis la classe principale
BASE_PACKAGE=$(grep "^package " "$MAIN_CLASS" | sed 's/package //;s/;//' | tr -d ' ')
BASE_PATH=$(echo "$BASE_PACKAGE" | tr '.' '/')

echo -e "${GREEN}✅ Package détecté : ${BOLD}${BASE_PACKAGE}${NC}"

# ── Chemin destination ───────────────────────────────────────
SECURITY_DIR="src/main/java/${BASE_PATH}/security"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/src/main/java/org/sid/security"

echo -e "${YELLOW}📁 Création du dossier : ${SECURITY_DIR}${NC}"
mkdir -p "$SECURITY_DIR"

# ── Copie + remplacement du package ─────────────────────────
echo -e "${YELLOW}📋 Copie des fichiers de sécurité...${NC}"

for FILE in SecurityConstants.java UserDetailsServiceImpl.java \
            JWTAuthenticationFilter.java JWTAuthorizationFilter.java \
            SecurityConfig.java; do

    sed "s|package org.sid.security;|package ${BASE_PACKAGE}.security;|g" \
        "${SOURCE_DIR}/${FILE}" > "${SECURITY_DIR}/${FILE}"
    echo -e "   ${GREEN}✔${NC} ${FILE}"
done

# ── Mise à jour du pom.xml ───────────────────────────────────
echo -e "\n${YELLOW}📦 Vérification des dépendances dans pom.xml...${NC}"

POM="pom.xml"

add_dep_if_missing() {
    local GROUP="$1" ARTIFACT="$2" EXTRA="$3"
    if ! grep -q "<artifactId>${ARTIFACT}</artifactId>" "$POM"; then
        # Insère avant </dependencies>
        BLOCK="        <dependency>\n            <groupId>${GROUP}<\/groupId>\n            <artifactId>${ARTIFACT}<\/artifactId>"
        [ -n "$EXTRA" ] && BLOCK="${BLOCK}\n${EXTRA}"
        BLOCK="${BLOCK}\n        <\/dependency>"
        sed -i "s|<\/dependencies>|${BLOCK}\n    <\/dependencies>|" "$POM"
        echo -e "   ${GREEN}✔${NC} Ajouté : ${ARTIFACT}"
    else
        echo -e "   ${CYAN}↩${NC} Déjà présent : ${ARTIFACT}"
    fi
}

add_dep_if_missing "org.springframework.boot" "spring-boot-starter-security"
add_dep_if_missing "io.jsonwebtoken" "jjwt-api" \
    "            <version>0.11.5<\/version>"
add_dep_if_missing "io.jsonwebtoken" "jjwt-impl" \
    "            <version>0.11.5<\/version>\n            <scope>runtime<\/scope>"
add_dep_if_missing "io.jsonwebtoken" "jjwt-jackson" \
    "            <version>0.11.5<\/version>\n            <scope>runtime<\/scope>"

# ── Résumé ───────────────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════╗"
echo -e "║   ✅ Installation terminée !                     ║"
echo -e "╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Package sécurité :${NC} ${BASE_PACKAGE}.security"
echo -e "  ${BOLD}Fichiers créés   :${NC}"
for FILE in SecurityConstants.java UserDetailsServiceImpl.java \
            JWTAuthenticationFilter.java JWTAuthorizationFilter.java \
            SecurityConfig.java; do
    echo -e "     📄 ${SECURITY_DIR}/${FILE}"
done

echo ""
echo -e "${YELLOW}${BOLD}➡  Prochaines étapes :${NC}"
echo -e "  1. Ouvre ${SECURITY_DIR}/UserDetailsServiceImpl.java"
echo -e "     et connecte-le à ton repository (ex: CustomerRepository)"
echo -e "  2. Ajoute @PreAuthorize sur tes RestControllers si besoin"
echo -e "  3. Lance : ${BOLD}./mvnw spring-boot:run${NC}"
echo -e "  4. Test login : POST http://localhost:8080/auth/login"
echo -e "     Body JSON : {\"username\":\"admin\", \"password\":\"1234\"}"
echo ""

# ── Git commit (optionnel) ───────────────────────────────────
if [ -d ".git" ]; then
    echo -e "${CYAN}Git détecté. Veux-tu committer automatiquement ? (o/N)${NC}"
    read -r REPLY
    if [[ "$REPLY" =~ ^[Oo]$ ]]; then
        git add "$SECURITY_DIR" "$POM"
        git commit -m "feat: add Spring Security + JWT security layer

- SecurityConfig: CORS, CSRF off, stateless sessions
- JWTAuthenticationFilter: login → generates JWT token
- JWTAuthorizationFilter: validates JWT on every request
- UserDetailsServiceImpl: user loading for Spring Security
- SecurityConstants: JWT config (secret, expiry, header)
- pom.xml: added spring-security, jjwt-api/impl/jackson deps"
        echo -e "${GREEN}✅ Commit effectué !${NC}"
        echo ""
        echo -e "${CYAN}Veux-tu aussi faire le push ? (o/N)${NC}"
        read -r PUSH_REPLY
        if [[ "$PUSH_REPLY" =~ ^[Oo]$ ]]; then
            git push
            echo -e "${GREEN}✅ Push effectué !${NC}"
        fi
    fi
fi

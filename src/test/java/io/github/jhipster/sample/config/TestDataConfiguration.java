package io.github.jhipster.sample.config;

import io.github.jhipster.sample.domain.Authority;
import io.github.jhipster.sample.repository.AuthorityRepository;
import io.github.jhipster.sample.security.AuthoritiesConstants;
import org.springframework.boot.test.context.TestConfiguration;

import jakarta.annotation.PostConstruct;

/**
 * Test configuration to initialize test data.
 */
@TestConfiguration
public class TestDataConfiguration {

    private final AuthorityRepository authorityRepository;

    public TestDataConfiguration(AuthorityRepository authorityRepository) {
        this.authorityRepository = authorityRepository;
    }

    /**
     * Initialize authorities for tests.
     * This runs after Hibernate has created the schema.
     */
    @PostConstruct
    public void initTestData() {
        // Create authorities if they don't exist
        createAuthorityIfNotExists(AuthoritiesConstants.ADMIN);
        createAuthorityIfNotExists(AuthoritiesConstants.USER);
        createAuthorityIfNotExists(AuthoritiesConstants.ANONYMOUS);
    }

    private void createAuthorityIfNotExists(String authorityName) {
        if (!authorityRepository.existsById(authorityName)) {
            Authority authority = new Authority();
            authority.setName(authorityName);
            authorityRepository.save(authority);
        }
    }
}

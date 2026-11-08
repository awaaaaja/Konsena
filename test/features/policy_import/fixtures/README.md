# Policy import fixtures

- `password_protected.pdf` is the AES-256, one-page PDF test fixture from the
  MIT-licensed `pdfrx_engine` 0.9.1 package's `test/assets/encrypted.pdf`.
  Its documented user password is `user`; the test also uses an incorrect
  password to verify recoverable handling. It contains no user or production
  document data.
- Born-digital and scanned PDFs are generated in memory by the processor tests
  so page text and image payloads remain small and reviewable in this repository.

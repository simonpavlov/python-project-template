"""Basic smoke tests for the package."""


class TestPackageImport:
    """Verify the package can be imported and has expected attributes."""

    def test_import_package(self) -> None:
        import my_package

        assert my_package is not None

    def test_version_exists(self) -> None:
        from my_package import __version__

        assert isinstance(__version__, str)
        assert len(__version__) > 0

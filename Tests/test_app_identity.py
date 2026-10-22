"""Guard the fork's identity against collisions with the original app."""
from pathlib import Path
import re
import unittest


class AppIdentityTests(unittest.TestCase):
    def test_debug_and_release_have_one_distinct_fork_identity(self):
        root = Path(__file__).resolve().parents[1]
        project = (root / "Online Indicator.xcodeproj/project.pbxproj").read_text()
        identifiers = re.findall(r'PRODUCT_BUNDLE_IDENTIFIER = "([^"]+)";', project)
        self.assertEqual(len(identifiers), 2, "Check both Debug and Release")
        self.assertEqual(len(set(identifiers)), 1, "Configurations must share an identity")
        self.assertNotEqual(identifiers[0], "in.bornexplorer.Online-Indicator",
                            "The fork must not share the original app's bundle ID")
        script = (root / "build-and-run.sh").read_text()
        expected = re.search(r'^expected_bundle_id="([^"]+)"$', script, re.MULTILINE)
        self.assertIsNotNone(expected, "Installer must specify the expected app identity")
        self.assertEqual(expected.group(1), identifiers[0],
                         "Installer and Xcode must agree on the fork's identity")


if __name__ == "__main__":
    unittest.main()

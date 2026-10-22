"""Keep the distributed version consistent with the project and documentation."""
from pathlib import Path
import plistlib
import re
import unittest


class ReleaseMetadataTests(unittest.TestCase):
    def test_version_flows_from_xcode_through_plist_and_readme(self):
        root = Path(__file__).resolve().parents[1]
        project = (root / "Online Indicator.xcodeproj/project.pbxproj").read_text()
        versions = re.findall(r"MARKETING_VERSION = ([^;]+);", project)
        builds = re.findall(r"CURRENT_PROJECT_VERSION = ([^;]+);", project)
        self.assertEqual(len(versions), 2, "Check Debug and Release")
        self.assertEqual(len(builds), 2)
        self.assertEqual(len(set(versions)), 1)
        self.assertEqual(len(set(builds)), 1)
        version, build = versions[0], builds[0]
        self.assertRegex(version, r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
        self.assertRegex(build, r"^[1-9]\d*$")

        with (root / "Online-Indicator-Info.plist").open("rb") as source:
            plist = plistlib.load(source)
        self.assertEqual(plist["CFBundleShortVersionString"], "$(MARKETING_VERSION)")
        self.assertEqual(plist["CFBundleVersion"], "$(CURRENT_PROJECT_VERSION)")

        readme = (root / "README.md").read_text()
        self.assertIn(f"**{version} (build {build})**", readme)
        self.assertIn(f"badge/version-{version}-", readme)
        self.assertNotIn("CFBundleVersion $gitHash", project)


if __name__ == "__main__":
    unittest.main()

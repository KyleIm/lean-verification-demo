"""The legacy config and a paired list both produce independently selectable problems."""
import json
import importlib.util
from pathlib import Path
import tempfile
import unittest
import verify

_evidence_path = Path(__file__).resolve().parents[1] / 'skills/physics-lean-formalizer/scripts/check_run.py'
_spec = importlib.util.spec_from_file_location('physics_evidence_check', _evidence_path)
evidence_check = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(evidence_check)


class ConfigDiscoveryTests(unittest.TestCase):
    def discover(self, payload, evidence=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pair = root / 'LeanVerificationDemo/PhysicsDemo/P15P16'
            pair.mkdir(parents=True)
            (pair / 'verification.json').write_text(json.dumps(payload))
            if evidence:
                return evidence_check.load_configs(root)
            previous = verify.ROOT
            try:
                verify.ROOT = root
                return verify.discover_problems()
            finally:
                verify.ROOT = previous

    def config(self, code, source):
        path = 'LeanVerificationDemo/PhysicsDemo/P15P16/'
        return dict(id=source, title=code, code=code, domain='physics',
                    problem_file=path+'Problem'+source+'.lean',
                    candidate_file=path+'Candidate'+source+'.lean',
                    verify_file=path+'Verify.lean',
                    annotated_file=path+'CandidateAnnotated'+source+'.lean',
                    pairing_walkthrough_file=path+'PairingWalkthrough.lean',
                    mutation_manifest=path+'mutations.json',
                    trusted_type_display='TrustedPhysicsProblem data',
                    candidate_term_display='Candidate.solution data',
                    required_judgment_display='Candidate.solution data : TrustedPhysicsProblem data')

    def test_legacy_object_is_unchanged(self):
        records = self.discover(self.config('P15', '764'))
        self.assertEqual([x.code for x in records], ['P15'])
        self.assertEqual(records[0].problem_file.name, 'Problem764.lean')

    def test_pair_is_independently_selectable_by_code_and_source(self):
        records = self.discover([self.config('P15', '764'), self.config('P16', '766')])
        self.assertEqual([x.code for x in records], ['P15', 'P16'])
        self.assertEqual(verify.select_problem(records, 'P15').id, '764')
        self.assertEqual(verify.select_problem(records, '766').code, 'P16')
        self.assertEqual(records[1].candidate_file.name, 'Candidate766.lean')

    def test_evidence_checker_accepts_legacy_and_pair(self):
        legacy = self.discover(self.config('P15', '764'), evidence=True)
        pair = self.discover([self.config('P15', '764'), self.config('P16', '766')], evidence=True)
        self.assertEqual([x['code'] for x in legacy], ['P15'])
        self.assertEqual([x['code'] for x in pair], ['P15', 'P16'])


if __name__ == '__main__':
    unittest.main()

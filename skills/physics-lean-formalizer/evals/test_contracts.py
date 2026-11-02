"""Contract invariants and evidence scanner regression tests (no provider calls)."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT/'scripts'/f'{name}.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module

validate = load('validate_contract').validate
lean_code = load('check_run').lean_code
contained = load('check_run').contained


def report():
    check = {'status':'passed','evidence':['Verify.lean:checked'],'reason':None}
    return {'schema_version':'1.0.0','skill_version':'0.1.0','status':'success',
      'problem_id':'test','problem_code':'P14','formalization_path':'LeanVerificationDemo/PhysicsDemo/P14',
      'repository_commit':'db175110266e96e4ee77b340697e9b7b34e98968','input_sha256':'0'*64,
      'dependency_context':{'lean_toolchain':'leanprover/lean4:v4.35.0','mathlib_rev':'1'*40,'physlib_rev':'2'*40},
      'physlib_reused':[],'physlibtemp_added':[], 'units_checked':copy.deepcopy(check),
      'approximation_audit':{'status':'exact_only','claims':[],'evidence':[]},
      'build_status':copy.deepcopy(check),'verification_status':{key:copy.deepcopy(check) for key in
        ['pairing','annotated','walkthrough','axioms','non_vacuity','negative_cases','mutations','regressions','source_fidelity','answer_separation','reuse_dependency']},
      'failure_category':None,'last_completed_stage':'acceptance','retry_recommendation':'none',
      'artifacts':[{'path':'Problem.lean','sha256':'3'*64}], 'omitted_artifacts':[],
      'evidence_path':'evidence.json','notes':[]}


class Contracts(unittest.TestCase):
    def test_valid_input(self):
        validate('input',json.loads((ROOT/'evals/input.example.json').read_text()))

    def test_bulk_payload_rejected(self):
        value=json.loads((ROOT/'evals/input.example.json').read_text()); value['problems']=[]
        with self.assertRaises(ValueError): validate('input',value)

    def test_skip_never_becomes_pass(self):
        value=report(); value['verification_status']['mutations']={'status':'skipped','evidence':[],'reason':'Deferred empty manifest'}
        validate('report',value)
        self.assertEqual(value['verification_status']['mutations']['status'],'skipped')
        value['verification_status']['mutations']['reason']=None
        with self.assertRaises(ValueError): validate('report',value)

    def test_success_cannot_hide_failure(self):
        for key in ['pairing','axioms','source_fidelity','answer_separation']:
            value=report(); value['verification_status'][key]['status']='failed'
            with self.assertRaises(ValueError): validate('report',value)
        value=report(); value['units_checked']['status']='not_run'; value['units_checked']['reason']='Unavailable'
        with self.assertRaises(ValueError): validate('report',value)
        value=report(); value['approximation_audit']['status']='unresolved'
        with self.assertRaises(ValueError): validate('report',value)

    def test_early_deferral_without_lean_artifacts(self):
        value=report(); value.update(status='deferred',formalization_path=None,artifacts=[],evidence_path=None,
              failure_category='missing_diagram_information',last_completed_stage='ingest',retry_recommendation='human_review')
        for check in [value['units_checked'],value['build_status'],*value['verification_status'].values()]:
            check.update(status='not_run',evidence=[],reason='Essential diagram missing')
        validate('report',value)
        value['failure_category']=None
        with self.assertRaises(ValueError): validate('report',value)

    def test_path_escape_and_symlink(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp).resolve(); (root/'escape').symlink_to('/tmp')
            with self.assertRaises(ValueError): contained(root,'../other')
            with self.assertRaises(ValueError): contained(root,'escape/outside')

    def test_admission_screen_ignores_nested_comments_and_strings(self):
        source='/- sorry /- axiom -/ admit -/\ndef s := "sorry \\" axiom"\n-- sorry\ntheorem t : True := by sorry'
        code=lean_code(source)
        self.assertEqual(code.count('sorry'),1)
        self.assertNotIn('axiom',code)


if __name__ == '__main__': unittest.main()

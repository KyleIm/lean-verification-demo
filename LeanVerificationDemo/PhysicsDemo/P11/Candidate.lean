import LeanVerificationDemo.PhysicsDemo.P11.Problem

namespace LeanVerificationDemo.PhysicsDemo.P11.Candidate
open MeasureTheory

lemma point_eq_iff (x y u v : ℝ) : point x y = point u v ↔ x = u ∧ y = v := by
  constructor
  · intro h
    exact ⟨congrArg (fun p : Plane => p 0) h, congrArg (fun p : Plane => p 1) h⟩
  · rintro ⟨rfl, rfl⟩
    rfl

lemma tan_pos (g : Geometry) : 0 < Real.tan g.α :=
  Real.tan_pos_of_pos_of_lt_pi_div_two g.angle_pos g.angle_lt
lemma slope_pos (g : Geometry) : 0 < slope g := one_div_pos.mpr (tan_pos g)
lemma base_pos (g : Geometry) : 0 < baseHeight g := mul_pos g.l_pos (slope_pos g)

/-- Actual Mathlib reflection, not an assumed screen-intersection formula:
the horizontal component is preserved and the normal component reverses. -/
lemma reflection_geometry (g : Geometry) : reflectedDirection g = point 1 (slope g) := by
  unfold reflectedDirection mirrorDirection
  rw [Submodule.reflection_singleton_apply]
  ext i
  fin_cases i <;> norm_num [point, incomingDirection, EuclideanSpace.inner_eq_star_dotProduct,
    dotProduct, Fin.sum_univ_two, EuclideanSpace.norm_sq_eq]

lemma incident_ray_coordinates (g : Geometry) (r t : ℝ) :
    incidentRay g r t = point (r + t) (-slope g * t) := by
  ext i
  fin_cases i <;> simp [incidentRay, incomingDirection, point] <;> ring

lemma reflected_ray_coordinates (g : Geometry) (r t : ℝ) :
    reflectedRay g r t = point (r + t) (slope g * t) := by
  rw [reflectedRay, reflection_geometry]
  ext i
  fin_cases i <;> simp [point] <;> ring

lemma direct_ray_coordinates (g : Geometry) (z t : ℝ) :
    directRay g z t = point (g.l + t) (z - slope g * t) := by
  ext i
  fin_cases i <;> simp [directRay, incomingDirection, point] <;> ring

lemma screen_hit_iff (g : Geometry) (r z : ℝ) :
    ScreenHit g r z ↔ r ≤ g.l ∧ z = (g.l - r) * slope g := by
  unfold ScreenHit
  simp_rw [reflected_ray_coordinates, point_eq_iff]
  constructor
  · rintro ⟨t, ht, hx, hy⟩
    have htime : t = g.l - r := by linarith
    subst t
    exact ⟨by linarith, by nlinarith⟩
  · rintro ⟨hr, hz⟩
    refine ⟨g.l - r, sub_nonneg.mpr hr, ?_, ?_⟩ <;> nlinarith

/-- Every screen height has exactly one mirror reflection point. -/
lemma screen_hit_unique_iff (g : Geometry) (r z : ℝ) :
    ScreenHit g r z ↔ 0 ≤ z ∧ r = g.l - z / slope g := by
  rw [screen_hit_iff]
  have hq := slope_pos g
  constructor
  · rintro ⟨hr, hz⟩
    have hquot : z / slope g = g.l - r := (div_eq_iff hq.ne').2 hz
    exact ⟨by nlinarith, by linarith⟩
  · rintro ⟨hz, rfl⟩
    constructor
    · exact sub_le_self _ (div_nonneg hz hq.le)
    · field_simp
      ring

lemma incident_blocked_iff (g : Geometry) (r : ℝ) :
    IncidentBlocked g r ↔ 0 ≤ r ∧ r * slope g ≤ g.h := by
  unfold IncidentBlocked
  simp_rw [incident_ray_coordinates, point_eq_iff]
  have hq := slope_pos g
  constructor
  · rintro ⟨u, hu, t, ht, hx, hy⟩
    constructor <;> nlinarith [hu.1, hu.2]
  · rintro ⟨hr, hh⟩
    refine ⟨r * slope g, ⟨mul_nonneg hr hq.le, hh⟩, -r, by linarith, ?_, ?_⟩ <;> ring

lemma outgoing_blocked_iff (g : Geometry) (r : ℝ) :
    OutgoingBlocked g r ↔ r ≤ 0 ∧ -r * slope g ≤ g.h := by
  unfold OutgoingBlocked
  simp_rw [reflected_ray_coordinates, point_eq_iff]
  have hq := slope_pos g
  constructor
  · rintro ⟨u, hu, t, ht, hend, hx, hy⟩
    constructor <;> nlinarith [hu.1, hu.2]
  · rintro ⟨hr, hh⟩
    refine ⟨-r * slope g, ⟨mul_nonneg (by linarith) hq.le, hh⟩, -r,
      by linarith, by linarith [g.l_pos], ?_, ?_⟩ <;> ring

lemma direct_blocked_iff (g : Geometry) (z : ℝ) :
    z ∈ directBlocked g ↔ 0 ≤ z ∧ z + baseHeight g ≤ g.h := by
  unfold directBlocked
  simp_rw [direct_ray_coordinates, point_eq_iff]
  have hH := base_pos g
  constructor
  · rintro ⟨hz, u, hu, t, ht, hx, hy⟩
    constructor
    · exact hz
    · have htime : t = -g.l := by linarith
      subst t
      dsimp [baseHeight]
      nlinarith [hu.2]
  · rintro ⟨hz, hh⟩
    refine ⟨hz, z + baseHeight g, ⟨by linarith, hh⟩, -g.l,
      by linarith [g.l_pos], by ring, ?_⟩
    dsimp [baseHeight]
    ring

/-- Solving ray/object and ray/screen intersections gives the upper/lower
boundary heights H+h and H-h. The latter can be below the physical screen. -/
lemma boundary_ray_intersections (g : Geometry) :
    reflectedRay g (-g.h / slope g) (g.l + g.h / slope g) =
      point g.l (baseHeight g + g.h) ∧
    incidentRay g (g.h / slope g) (-g.h / slope g) = point 0 g.h ∧
    reflectedRay g (g.h / slope g) (g.l - g.h / slope g) =
      point g.l (baseHeight g - g.h) := by
  simp_rw [reflected_ray_coordinates, incident_ray_coordinates, point_eq_iff]
  dsimp [baseHeight]
  repeat' constructor
  all_goals field_simp [(slope_pos g).ne'] <;> ring

lemma upright_shadow_interval (g : Geometry) :
    uprightShadow g = Set.Icc (baseHeight g) (baseHeight g + g.h) := by
  ext z
  simp only [uprightShadow, Set.mem_ofPred_eq, Set.mem_Icc, screen_hit_unique_iff,
    outgoing_blocked_iff]
  have hq := slope_pos g
  have hH := base_pos g
  constructor
  · rintro ⟨hz, r, ⟨_, hr⟩, hr0, hrh⟩
    have hprod : r * slope g = baseHeight g - z := by
      rw [hr]
      dsimp [baseHeight]
      field_simp
    constructor <;> nlinarith
  · rintro ⟨hz, hh⟩
    have hz0 : 0 ≤ z := by linarith
    refine ⟨hz0, g.l - z / slope g, ⟨hz0, rfl⟩, ?_, ?_⟩
    · apply sub_nonpos.mpr
      apply (le_div_iff₀ hq).2
      exact hz
    · have heq : -(g.l - z / slope g) * slope g = z - baseHeight g := by
        dsimp [baseHeight]
        field_simp
        ring
      rw [heq]
      linarith

lemma inverted_shadow_interval (g : Geometry) :
    invertedShadow g = Set.Icc (max 0 (baseHeight g - g.h)) (baseHeight g) := by
  ext z
  simp only [invertedShadow, Set.mem_ofPred_eq, Set.mem_Icc, screen_hit_unique_iff,
    incident_blocked_iff, max_le_iff]
  have hq := slope_pos g
  constructor
  · rintro ⟨hz, r, ⟨_, hr⟩, hr0, hrh⟩
    have hprod : r * slope g = baseHeight g - z := by
      rw [hr]
      dsimp [baseHeight]
      field_simp
    exact ⟨⟨hz, by nlinarith⟩, by nlinarith⟩
  · rintro ⟨⟨hz, hh⟩, hzH⟩
    refine ⟨hz, g.l - z / slope g, ⟨hz, rfl⟩, ?_, ?_⟩
    · apply sub_nonneg.mpr
      apply (div_le_iff₀ hq).2
      exact hzH
    · have heq : (g.l - z / slope g) * slope g = baseHeight g - z := by
        dsimp [baseHeight]
        field_simp
      rw [heq]
      linarith

/-- The chosen direction has horizontal/normal component ratio tan α; α is
consistently the incidence angle to the vertical normal, not to the surface. -/
lemma incidence_ratio (g : Geometry) :
    (incomingDirection g 0) / (-(incomingDirection g 1)) = Real.tan g.α := by
  change 1 / (-(-slope g)) = Real.tan g.α
  simp [slope]

lemma reflected_shadow_interval (g : Geometry) :
    reflectedBlocked g = Set.Icc (max 0 (baseHeight g - g.h)) (baseHeight g + g.h) := by
  rw [reflectedBlocked, upright_shadow_interval, inverted_shadow_interval]
  ext z
  simp only [Set.mem_union, Set.mem_Icc]
  have hlo : max 0 (baseHeight g - g.h) ≤ baseHeight g :=
    max_le (base_pos g).le (by linarith [g.h_pos])
  constructor
  · rintro (hu | hi)
    · exact ⟨hlo.trans hu.1, hu.2⟩
    · exact ⟨hi.1, by linarith [hi.2, g.h_pos]⟩
  · rintro ⟨hloz, hz⟩
    by_cases h : z ≤ baseHeight g
    · exact Or.inr ⟨hloz, h⟩
    · exact Or.inl ⟨by linarith, hz⟩

lemma direct_subset_reflected (g : Geometry) : directBlocked g ⊆ reflectedBlocked g := by
  intro z hz
  rw [direct_blocked_iff] at hz
  rw [reflected_shadow_interval]
  exact ⟨max_le hz.1 (by linarith [hz.2]), by linarith [hz.2, base_pos g]⟩

lemma shadow_interval (g : Geometry) :
    shadow g = Set.Icc (max 0 (baseHeight g - g.h)) (baseHeight g + g.h) := by
  rw [shadow, Set.union_eq_right.mpr (direct_subset_reflected g), reflected_shadow_interval]

lemma fully_dark_interval (g : Geometry) : fullyDark g = Set.Icc 0 (g.h - baseHeight g) := by
  rw [fullyDark, Set.inter_eq_left.mpr (direct_subset_reflected g)]
  ext z
  rw [direct_blocked_iff]
  simp only [Set.mem_Icc]
  constructor <;> rintro ⟨hz, hh⟩ <;> constructor <;> linarith

/-- Set terminology matches the two independent illumination channels. -/
lemma darkness_channels (g : Geometry) {z : ℝ} (hz : 0 ≤ z) :
    (z ∈ fullyDark g ↔ ¬ directIlluminated g z ∧ ¬ reflectedIlluminated g z) ∧
    (z ∈ shadow g ↔ ¬ directIlluminated g z ∨ ¬ reflectedIlluminated g z) := by
  simp [fullyDark, shadow, directIlluminated, reflectedIlluminated, hz]

/-- Complement of reflected blockage really means availability of the unique
unobstructed reflected ray, not merely a name for an interval. -/
lemma reflected_availability (g : Geometry) (z : ℝ) :
    reflectedIlluminated g z ↔
      ∃ r, ScreenHit g r z ∧ ¬ (IncidentBlocked g r ∨ OutgoingBlocked g r) := by
  constructor
  · rintro ⟨hz, hclear⟩
    have hit : ScreenHit g (g.l - z / slope g) z :=
      (screen_hit_unique_iff g _ _).2 ⟨hz, rfl⟩
    refine ⟨_, hit, ?_⟩
    rintro (hi | ho)
    · exact hclear (Or.inr ⟨hz, _, hit, hi⟩)
    · exact hclear (Or.inl ⟨hz, _, hit, ho⟩)
  · rintro ⟨r, hit, hclear⟩
    have hs := (screen_hit_unique_iff g _ _).1 hit
    refine ⟨hs.1, ?_⟩
    rintro (⟨_, r', hit', ho⟩ | ⟨_, r', hit', hi⟩)
    · have heq : r' = r := ((screen_hit_unique_iff g _ _).1 hit').2.trans hs.2.symm
      subst r'
      exact hclear (Or.inr ho)
    · have heq : r' = r := ((screen_hit_unique_iff g _ _).1 hit').2.trans hs.2.symm
      subst r'
      exact hclear (Or.inl hi)

/-- The top inverted boundary H-h reaches the mirror/screen bottom precisely
at l = h tan α. The threshold is derived, not a SourceData field. -/
lemma threshold_characterization (g : Geometry) :
    (baseHeight g - g.h = 0 ↔ g.l = g.h * Real.tan g.α) ∧
    (g.h ≤ baseHeight g ↔ FarScreen g) ∧
    (baseHeight g < g.h ↔ NearScreen g) := by
  have heq : baseHeight g = g.l / Real.tan g.α := by
    simp [baseHeight, slope, div_eq_mul_inv]
  rw [heq]
  unfold FarScreen NearScreen
  constructor
  · rw [sub_eq_zero, div_eq_iff (tan_pos g).ne']
  constructor
  · exact le_div_iff₀ (tan_pos g)
  · exact div_lt_iff₀ (tan_pos g)

/-- The top inverted boundary is a forward reflected ray reaching the physical
screen iff the source solution's far condition holds. This uses the derived
boundary-ray intersection, not a precomputed shadow endpoint premise. -/
lemma top_boundary_screen_iff (g : Geometry) :
    ScreenHit g (g.h / slope g) (baseHeight g - g.h) ↔ FarScreen g := by
  constructor
  · intro hit
    have hz := ((screen_hit_unique_iff g _ _).1 hit).1
    exact (threshold_characterization g).2.1.mp (by linarith)
  · intro far
    have hfar := (threshold_characterization g).2.1.mpr far
    refine ⟨g.l - g.h / slope g, ?_, (boundary_ray_intersections g).2.2⟩
    exact sub_nonneg.mpr ((div_le_iff₀ (slope_pos g)).2 hfar)

lemma interval_length (a b : ℝ) (hab : a ≤ b) :
    verticalLength (Set.Icc a b) = b - a := by
  unfold verticalLength
  rw [Real.volume_Icc, ENNReal.toReal_ofReal (sub_nonneg.mpr hab)]

lemma far_screen_shadow_structure (g : Geometry) (far : FarScreen g) : FarConclusion g := by
  have topHit := (top_boundary_screen_iff g).mpr far
  have hz := ((screen_hit_unique_iff g _ _).1 topHit).1
  have hfar : g.h ≤ baseHeight g := by linarith
  have hu := upright_shadow_interval g
  have hi : invertedShadow g = Set.Icc (baseHeight g - g.h) (baseHeight g) := by
    rw [inverted_shadow_interval, max_eq_right (by linarith)]
  have hs : shadow g = Set.Icc (baseHeight g - g.h) (baseHeight g + g.h) := by
    rw [shadow_interval, max_eq_right (by linarith)]
  refine
    { upright := hu
      inverted := hi
      total_interval := hs
      meeting_bases := ?_
      upright_length := ?_
      inverted_length := ?_
      total_length := ?_ }
  · rw [hu, hi]
    ext z
    simp only [Set.mem_inter_iff, Set.mem_Icc, Set.mem_singleton_iff]
    constructor
    · rintro ⟨hu, hi⟩
      linarith [hu.1, hi.2]
    · rintro rfl
      constructor <;> constructor <;> linarith [g.h_pos]
  · rw [hu, interval_length _ _ (by linarith [g.h_pos])]
    ring
  · rw [hi, interval_length _ _ (by linarith [g.h_pos])]
    ring
  · rw [hs, interval_length _ _ (by linarith [g.h_pos])]
    ring

lemma near_screen_shadow_structure (g : Geometry) (near : NearScreen g) : NearConclusion g := by
  have hnear : baseHeight g < g.h := (threshold_characterization g).2.2.mpr near
  have hs : shadow g = Set.Icc 0 (baseHeight g + g.h) := by
    rw [shadow_interval, max_eq_left (by linarith)]
  have hlength : verticalLength (shadow g) = baseHeight g + g.h := by
    rw [hs, interval_length _ _ (by linarith [base_pos g, g.h_pos])]
    ring
  have hdark := fully_dark_interval g
  have hdarkLength : verticalLength (fullyDark g) = g.h - baseHeight g := by
    rw [hdark, interval_length _ _ (by linarith)]
    ring
  exact
    { total_interval := hs
      total_length := hlength
      shorter := by rw [hlength]; linarith
      dark_interval := hdark
      positive_dark_length := by rw [hdarkLength]; linarith }

/-- Terminology correction: upright/inverted are two reflected-channel losses.
The source's 2h shadow is their union, not a far-screen loss of direct sunlight.
Both regimes are conclusions conditional on the parameter geometry. -/
theorem solution (g : Geometry) : TrustedPhysicsProblem g := by
  have farScreen : FarScreen g → FarConclusion g := fun hf => far_screen_shadow_structure g hf
  have nearScreen : NearScreen g → NearConclusion g := fun hn => near_screen_shadow_structure g hn
  -- Far: each part has length h, bases meet at H, union length 2h.
  -- Near: union length H+h < 2h; fully dark interval [0,h-H] has positive length.
  exact ⟨farScreen, nearScreen⟩

end LeanVerificationDemo.PhysicsDemo.P11.Candidate

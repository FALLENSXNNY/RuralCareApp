import 'dart:convert';
import '../models/child_care.dart';
import '../storage/local_storage_service.dart';

abstract class ChildCareRepository {
  Future<List<ChildVaccine>> getVaccineSchedule();
  Future<void> toggleVaccineStatus(String vaccineId, bool isCompleted);
  List<ChildMilestone> getDevelopmentalMilestones();
  List<PostnatalVisit> getPostnatalCareSchedule();
  Future<List<FetalKickSession>> getKickSessions();
  Future<void> saveKickSession(FetalKickSession session);
}

class ApiChildCareRepository implements ChildCareRepository {
  final LocalStorageService _storage;

  ApiChildCareRepository(this._storage);

  @override
  Future<List<ChildVaccine>> getVaccineSchedule() async {
    final completedIds = _storage.completedVaccines.toSet();

    final allVaccines = [
      // ── At Birth ──
      const ChildVaccine(
        id: 'vac_birth_bcg',
        name: 'BCG',
        fullName: 'Bacillus Calmette–Guérin',
        ageGroup: 'At Birth (within 1 year)',
        ageBracket: ChildAgeBracket.atBirth,
        route: 'Intradermal',
        site: 'Left upper arm',
        dose: '0.1 ml (0.05 ml if < 1 month)',
        preventsDiseases: ['Tuberculosis (TB)', 'TB Meningitis'],
      ),
      const ChildVaccine(
        id: 'vac_birth_opv0',
        name: 'OPV-0',
        fullName: 'Oral Polio Vaccine (Birth Dose)',
        ageGroup: 'At Birth (within first 15 days)',
        ageBracket: ChildAgeBracket.atBirth,
        route: 'Oral',
        site: 'Mouth',
        dose: '2 Drops',
        preventsDiseases: ['Poliomyelitis (Infantile Paralysis)'],
      ),
      const ChildVaccine(
        id: 'vac_birth_hepb',
        name: 'Hepatitis B (Birth Dose)',
        fullName: 'Hepatitis B Birth Dose',
        ageGroup: 'At Birth (within 24 hours)',
        ageBracket: ChildAgeBracket.atBirth,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Left)',
        dose: '0.5 ml',
        preventsDiseases: ['Perinatal Hepatitis B Liver Infection'],
      ),

      // ── 6 Weeks ──
      const ChildVaccine(
        id: 'vac_6w_penta1',
        name: 'Pentavalent-1',
        fullName: 'DTP-HepB-Hib 1st Dose',
        ageGroup: '6 Weeks',
        ageBracket: ChildAgeBracket.weeks6,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Left)',
        dose: '0.5 ml',
        preventsDiseases: ['Diphtheria', 'Pertussis (Whooping Cough)', 'Tetanus', 'Hepatitis B', 'Haemophilus influenzae type B pneumonia/meningitis'],
      ),
      const ChildVaccine(
        id: 'vac_6w_opv1',
        name: 'OPV-1',
        fullName: 'Oral Polio Vaccine Dose 1',
        ageGroup: '6 Weeks',
        ageBracket: ChildAgeBracket.weeks6,
        route: 'Oral',
        site: 'Mouth',
        dose: '2 Drops',
        preventsDiseases: ['Poliovirus Types 1 & 3'],
      ),
      const ChildVaccine(
        id: 'vac_6w_rota1',
        name: 'Rotavirus-1',
        fullName: 'Rotavirus Vaccine Dose 1',
        ageGroup: '6 Weeks',
        ageBracket: ChildAgeBracket.weeks6,
        route: 'Oral',
        site: 'Mouth',
        dose: '5 Drops / 2.5 ml',
        preventsDiseases: ['Severe Rotaviral Diarrhea'],
      ),
      const ChildVaccine(
        id: 'vac_6w_fipv1',
        name: 'fIPV-1',
        fullName: 'Fractional Inactivated Polio Vaccine 1',
        ageGroup: '6 Weeks',
        ageBracket: ChildAgeBracket.weeks6,
        route: 'Intradermal',
        site: 'Right upper arm',
        dose: '0.1 ml',
        preventsDiseases: ['All Poliovirus Strains'],
      ),
      const ChildVaccine(
        id: 'vac_6w_pcv1',
        name: 'PCV-1',
        fullName: 'Pneumococcal Conjugate Vaccine 1',
        ageGroup: '6 Weeks',
        ageBracket: ChildAgeBracket.weeks6,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Right)',
        dose: '0.5 ml',
        preventsDiseases: ['Severe Pneumonia', 'Pneumococcal Meningitis'],
      ),

      // ── 10 Weeks ──
      const ChildVaccine(
        id: 'vac_10w_penta2',
        name: 'Pentavalent-2',
        fullName: 'DTP-HepB-Hib 2nd Dose',
        ageGroup: '10 Weeks',
        ageBracket: ChildAgeBracket.weeks10,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Left)',
        dose: '0.5 ml',
        preventsDiseases: ['Diphtheria', 'Pertussis', 'Tetanus', 'Hepatitis B', 'Hib'],
      ),
      const ChildVaccine(
        id: 'vac_10w_opv2',
        name: 'OPV-2',
        fullName: 'Oral Polio Vaccine Dose 2',
        ageGroup: '10 Weeks',
        ageBracket: ChildAgeBracket.weeks10,
        route: 'Oral',
        site: 'Mouth',
        dose: '2 Drops',
        preventsDiseases: ['Poliovirus'],
      ),
      const ChildVaccine(
        id: 'vac_10w_rota2',
        name: 'Rotavirus-2',
        fullName: 'Rotavirus Vaccine Dose 2',
        ageGroup: '10 Weeks',
        ageBracket: ChildAgeBracket.weeks10,
        route: 'Oral',
        site: 'Mouth',
        dose: '5 Drops / 2.5 ml',
        preventsDiseases: ['Rotavirus Diarrhea'],
      ),

      // ── 14 Weeks ──
      const ChildVaccine(
        id: 'vac_14w_penta3',
        name: 'Pentavalent-3',
        fullName: 'DTP-HepB-Hib 3rd Dose',
        ageGroup: '14 Weeks',
        ageBracket: ChildAgeBracket.weeks14,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Left)',
        dose: '0.5 ml',
        preventsDiseases: ['Diphtheria', 'Pertussis', 'Tetanus', 'Hepatitis B', 'Hib'],
      ),
      const ChildVaccine(
        id: 'vac_14w_opv3',
        name: 'OPV-3',
        fullName: 'Oral Polio Vaccine Dose 3',
        ageGroup: '14 Weeks',
        ageBracket: ChildAgeBracket.weeks14,
        route: 'Oral',
        site: 'Mouth',
        dose: '2 Drops',
        preventsDiseases: ['Poliovirus'],
      ),
      const ChildVaccine(
        id: 'vac_14w_rota3',
        name: 'Rotavirus-3',
        fullName: 'Rotavirus Vaccine Dose 3',
        ageGroup: '14 Weeks',
        ageBracket: ChildAgeBracket.weeks14,
        route: 'Oral',
        site: 'Mouth',
        dose: '5 Drops / 2.5 ml',
        preventsDiseases: ['Rotavirus Diarrhea'],
      ),
      const ChildVaccine(
        id: 'vac_14w_fipv2',
        name: 'fIPV-2',
        fullName: 'Fractional Inactivated Polio Vaccine 2',
        ageGroup: '14 Weeks',
        ageBracket: ChildAgeBracket.weeks14,
        route: 'Intradermal',
        site: 'Right upper arm',
        dose: '0.1 ml',
        preventsDiseases: ['Polio Strains'],
      ),
      const ChildVaccine(
        id: 'vac_14w_pcv2',
        name: 'PCV-2',
        fullName: 'Pneumococcal Conjugate Vaccine 2',
        ageGroup: '14 Weeks',
        ageBracket: ChildAgeBracket.weeks14,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Right)',
        dose: '0.5 ml',
        preventsDiseases: ['Pneumonia', 'Pneumococcal infections'],
      ),

      // ── 9–12 Months ──
      const ChildVaccine(
        id: 'vac_9m_mr1',
        name: 'MR-1',
        fullName: 'Measles & Rubella 1st Dose',
        ageGroup: '9 – 12 Months',
        ageBracket: ChildAgeBracket.months9to12,
        route: 'Subcutaneous',
        site: 'Right upper arm',
        dose: '0.5 ml',
        preventsDiseases: ['Measles (Khasra)', 'Congenital Rubella Syndrome'],
      ),
      const ChildVaccine(
        id: 'vac_9m_je1',
        name: 'JE-1',
        fullName: 'Japanese Encephalitis 1st Dose',
        ageGroup: '9 – 12 Months',
        ageBracket: ChildAgeBracket.months9to12,
        route: 'Subcutaneous',
        site: 'Left upper arm',
        dose: '0.5 ml',
        preventsDiseases: ['Japanese Encephalitis (Brain Fever)'],
      ),
      const ChildVaccine(
        id: 'vac_9m_pcv_booster',
        name: 'PCV Booster',
        fullName: 'Pneumococcal Conjugate Booster',
        ageGroup: '9 – 12 Months',
        ageBracket: ChildAgeBracket.months9to12,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Right)',
        dose: '0.5 ml',
        preventsDiseases: ['Pneumonia Booster Protection'],
      ),
      const ChildVaccine(
        id: 'vac_9m_vita1',
        name: 'Vitamin A (Dose 1)',
        fullName: 'Vitamin A Syrup 1st Dose',
        ageGroup: '9 Months (with MR-1)',
        ageBracket: ChildAgeBracket.months9to12,
        route: 'Oral',
        site: 'Mouth',
        dose: '1 ml (1 Lakh IU)',
        preventsDiseases: ['Night Blindness', 'Immune Deficiency'],
      ),

      // ── 16–24 Months ──
      const ChildVaccine(
        id: 'vac_16m_mr2',
        name: 'MR-2',
        fullName: 'Measles & Rubella 2nd Dose',
        ageGroup: '16 – 24 Months',
        ageBracket: ChildAgeBracket.months16to24,
        route: 'Subcutaneous',
        site: 'Right upper arm',
        dose: '0.5 ml',
        preventsDiseases: ['Measles & Rubella Long-term Immunity'],
      ),
      const ChildVaccine(
        id: 'vac_16m_dpt_b1',
        name: 'DPT Booster-1',
        fullName: 'Diphtheria, Pertussis, Tetanus Booster 1',
        ageGroup: '16 – 24 Months',
        ageBracket: ChildAgeBracket.months16to24,
        route: 'Intramuscular',
        site: 'Anterolateral mid-thigh (Left)',
        dose: '0.5 ml',
        preventsDiseases: ['Diphtheria', 'Pertussis', 'Tetanus Booster'],
      ),
      const ChildVaccine(
        id: 'vac_16m_opv_b',
        name: 'OPV Booster',
        fullName: 'Oral Polio Vaccine Booster',
        ageGroup: '16 – 24 Months',
        ageBracket: ChildAgeBracket.months16to24,
        route: 'Oral',
        site: 'Mouth',
        dose: '2 Drops',
        preventsDiseases: ['Polio Booster'],
      ),

      // ── 5–6 Years ──
      const ChildVaccine(
        id: 'vac_5y_dpt_b2',
        name: 'DPT Booster-2',
        fullName: 'DPT 2nd Booster Dose',
        ageGroup: '5 – 6 Years',
        ageBracket: ChildAgeBracket.years5to6,
        route: 'Intramuscular',
        site: 'Upper arm (Deltoid)',
        dose: '0.5 ml',
        preventsDiseases: ['School-entry Diphtheria, Pertussis, Tetanus Protection'],
      ),
    ];

    return allVaccines.map((v) {
      final isDone = completedIds.contains(v.id);
      return v.copyWith(isCompleted: isDone);
    }).toList();
  }

  @override
  Future<void> toggleVaccineStatus(String vaccineId, bool isCompleted) async {
    await _storage.setVaccineCompleted(vaccineId, isCompleted);
  }

  @override
  List<ChildMilestone> getDevelopmentalMilestones() {
    return const [
      ChildMilestone(
        id: 'ms_2m',
        ageRange: '2 Months',
        title: 'Head Control & Social Smile',
        description: 'Baby begins smiling at familiar faces and lifts head momentarily while on tummy.',
        domain: MilestoneDomain.social,
        keyMilestones: [
          'Smiles spontaneously at mother/caregiver',
          'Lifts head and chest during tummy time',
          'Follows objects moving with eyes from side to side',
          'Makes cooing or gurgling sounds',
        ],
        stimulationTip: 'Talk and smile face-to-face with your baby. Provide supervised daily tummy time for 3–5 minutes.',
        redFlags: 'Does not react to loud noises or does not watch faces.',
      ),
      ChildMilestone(
        id: 'ms_6m',
        ageRange: '6 Months',
        title: 'Sitting with Support & Babbling',
        description: 'Introduction to complementary foods and developing trunk stability.',
        domain: MilestoneDomain.motor,
        keyMilestones: [
          'Rolls over from tummy to back and back to tummy',
          'Sits with hand support or in lap',
          'Passes toys from one hand to another',
          'Responds to own name and makes repetitive consonant sounds (ba-ba, ma-ma)',
        ],
        stimulationTip: 'Start soft mashed complementary foods (thick dal, khichdi, mashed banana) along with breast milk.',
        redFlags: 'Cannot roll in either direction or seems very stiff or floppy.',
      ),
      ChildMilestone(
        id: 'ms_12m',
        ageRange: '12 Months (1 Year)',
        title: 'Standing & First Words',
        description: 'Transitioning into toddlerhood, standing with support, and intentional communication.',
        domain: MilestoneDomain.motor,
        keyMilestones: [
          'Pulls up to stand and cruises along furniture',
          'Uses pincer grasp (thumb and forefinger) to pick up small food pieces',
          'Says 1–2 meaningful words like "Amma", "Papa"',
          'Waves "bye-bye" and plays peek-a-boo',
        ],
        stimulationTip: 'Encourage safe cruising. Feed 3–4 small nutritious meals daily with family food.',
        redFlags: 'Cannot stand with support or does not point or gesture.',
      ),
      ChildMilestone(
        id: 'ms_2y',
        ageRange: '2 Years (24 Months)',
        title: 'Independent Walking & 2-Word Phrases',
        description: 'Active exploration, running, jumping, and combining words.',
        domain: MilestoneDomain.speech,
        keyMilestones: [
          'Runs smoothly and kicks a small ball forward',
          'Speaks 2-word phrases like "Want milk", "Go out"',
          'Follows simple two-step instructions',
          'Drinks from a small cup and eats with a spoon',
        ],
        stimulationTip: 'Read picture storybooks aloud and ask child to identify animals and everyday objects.',
        redFlags: 'Cannot walk stably or uses fewer than 6 spoken words.',
      ),
    ];
  }

  @override
  List<PostnatalVisit> getPostnatalCareSchedule() {
    return const [
      PostnatalVisit(
        visitNumber: 1,
        timing: 'Within 24 Hours of Delivery',
        title: 'PNC Visit 1 (Institutional Delivery)',
        maternalChecks: [
          'Postpartum bleeding (Lochia) & uterine involution',
          'Blood pressure and temperature monitoring',
          'Perineal tear or cesarean wound inspection',
          'Breast examination and colostrum feeding initiation',
        ],
        newbornChecks: [
          'Birth weight, temperature, and skin-to-skin contact',
          'Immediate breastfeeding within 1 hour of birth',
          'Administration of birth dose vaccines (BCG, OPV-0, Hep-B)',
          'Check for congenital anomalies and breathing effort',
        ],
        isCompleted: true,
      ),
      PostnatalVisit(
        visitNumber: 2,
        timing: 'Day 3 after Delivery',
        title: 'PNC Visit 2 (Home Visit by ASHA)',
        maternalChecks: [
          'Check for excessive bleeding, foul lochia, or fever',
          'Breast engorgement or nipple soreness assistance',
          'Nutritional advice & rest compliance',
        ],
        newbornChecks: [
          'Neonatal jaundice check (yellowing of eyes/skin)',
          'Umbilical cord stump clean and dry (no powders or oils)',
          'Urine output (at least 6 wet diapers/cloths in 24h)',
          'Baby warmth (Kangaroo Mother Care if low birth weight)',
        ],
        isCompleted: true,
      ),
      PostnatalVisit(
        visitNumber: 3,
        timing: 'Day 7 after Delivery',
        title: 'PNC Visit 3',
        maternalChecks: [
          'Blood pressure check & maternal emotional wellbeing check',
          'Continuation of daily IFA and Calcium tablets',
        ],
        newbornChecks: [
          'Weight check (regaining birth weight)',
          'Exclusive breastfeeding confirmation (no water, honey, ghutti)',
          'Eye check for sticky discharge or redness',
        ],
      ),
      PostnatalVisit(
        visitNumber: 4,
        timing: 'Day 14 after Delivery',
        title: 'PNC Visit 4',
        maternalChecks: [
          'Perineal/cesarean wound healing status',
          'General energy, hydration, and postpartum depression screening',
        ],
        newbornChecks: [
          'Cord stump detachment status',
          'Active feeding pattern and weight progress',
        ],
      ),
      PostnatalVisit(
        visitNumber: 5,
        timing: 'Week 6 (42 Days)',
        title: 'PNC Visit 5 & First Vaccine Milestone',
        maternalChecks: [
          'Final postpartum checkup at PHC',
          'Postpartum contraception & family planning counselling (PPIUCD / Chhaya / Antara)',
        ],
        newbornChecks: [
          'First milestone vaccinations (Pentavalent-1, OPV-1, Rota-1, fIPV-1, PCV-1)',
          'Growth monitoring on MCP card',
        ],
      ),
    ];
  }

  @override
  Future<List<FetalKickSession>> getKickSessions() async {
    final raw = _storage.rawKickSessions;
    if (raw.isEmpty) {
      // Default starter sample sessions
      final now = DateTime.now();
      return [
        FetalKickSession(
          timestamp: now.subtract(const Duration(hours: 14)),
          kicksCount: 10,
          durationMinutes: 32,
          isNormal: true,
        ),
        FetalKickSession(
          timestamp: now.subtract(const Duration(days: 1, hours: 2)),
          kicksCount: 10,
          durationMinutes: 45,
          isNormal: true,
        ),
      ];
    }
    try {
      return raw.map((str) => FetalKickSession.fromJson(jsonDecode(str) as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveKickSession(FetalKickSession session) async {
    final jsonStr = jsonEncode(session.toJson());
    await _storage.saveKickSession(jsonStr);
  }
}

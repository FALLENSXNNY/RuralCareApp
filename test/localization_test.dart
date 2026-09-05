import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/providers/app_providers.dart';
import 'package:ruralcare/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('Supported locales include en, hi, and bn', () {
      expect(AppLocalizations.supportedLocales.map((l) => l.languageCode),
          containsAll(['en', 'hi', 'bn']));
      // Verify Bengali is specifically 'bn' and not 'be'
      expect(AppLocalizations.supportedLocales.map((l) => l.languageCode),
          isNot(contains('be')));
    });

    test('English translations provide correct source strings', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.appName, equals('RuralCare'));
      expect(l10n.navHome, equals('Home'));
      expect(l10n.navEmergency, equals('Emergency'));
      expect(l10n.navAiAssistant, equals('AI Health'));
      expect(l10n.navPregnancy, equals('Pregnancy'));
      expect(l10n.navFindCare, equals('Care'));
      expect(l10n.navRecords, equals('Records'));
      expect(l10n.navProfile, equals('Profile'));
      expect(l10n.directions, equals('Directions'));
      expect(l10n.callAmbulance, contains('108'));
    });

    test('Hindi translations provide natural Devanagari text', () {
      final l10n = AppLocalizations(const Locale('hi'));
      expect(l10n.appName, contains('रूरलकेयर'));
      expect(l10n.navHome, equals('होम'));
      expect(l10n.navEmergency, equals('आपातकालीन'));
      expect(l10n.navAiAssistant, equals('AI स्वास्थ्य'));
      expect(l10n.navPregnancy, equals('मातृ एवं शिशु'));
      expect(l10n.navFindCare, equals('अस्पताल'));
      expect(l10n.navRecords, equals('रिकॉर्ड्स'));
      expect(l10n.navProfile, equals('प्रोफ़ाइल'));
      expect(l10n.directions, equals('दिशा-निर्देश'));
      expect(l10n.callAmbulance, contains('108'));
    });

    test('Bengali translations provide natural Bengali text with bn locale', () {
      final l10n = AppLocalizations(const Locale('bn'));
      expect(l10n.appName, contains('রুরালকেয়ার'));
      expect(l10n.navHome, equals('হোম'));
      expect(l10n.navEmergency, equals('জরুরি'));
      expect(l10n.navAiAssistant, equals('এআই স্বাস্থ্য'));
      expect(l10n.navPregnancy, equals('মাতৃ ও শিশু'));
      expect(l10n.navFindCare, equals('হাসপাতাল'));
      expect(l10n.navRecords, equals('রেকর্ড'));
      expect(l10n.navProfile, equals('প্রোফাইল'));
      expect(l10n.directions, equals('পথনির্দেশ'));
      expect(l10n.callAmbulance, contains('১০৮'));
    });

    test('Parameter replacement works across all languages', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.greeting('Rahul'), equals('Hello, Rahul'));
      expect(hi.greeting('राहुल'), equals('नमस्ते, राहुल'));
      expect(bn.greeting('রাহুল'), equals('নমস্কার, রাহুল'));

      expect(en.currentWeek(24), equals('Week 24'));
      expect(hi.currentWeek(24), equals('सप्ताह 24'));
      expect(bn.currentWeek(24), equals('24 তম সপ্তাহ'));
    });

    test('Fallback to English when translation key is not found in target locale', () {
      final l10n = AppLocalizations(const Locale('hi'));
      // Translating a hypothetical key that only exists in English
      final translated = l10n.translate('nonExistentKey');
      expect(translated, equals('nonExistentKey'));
    });

    test('AppLocalizations.delegate correctly validates supported locales', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('hi')), isTrue);
      expect(delegate.isSupported(const Locale('bn')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
      expect(delegate.isSupported(const Locale('be')), isFalse);
    });

    test('Quick Action labels are translated across en, hi, bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.actionAskAi, equals('Ask\nAI'));
      expect(hi.actionAskAi, contains('AI'));
      expect(bn.actionAskAi, contains('এআই'));

      expect(en.actionTalkDoctor, equals('Talk to\nDoctor'));
      expect(hi.actionTalkDoctor, contains('डॉक्टर'));
      expect(bn.actionTalkDoctor, contains('ডাক্তার'));

      expect(en.actionFindFacility, equals('Find\nFacility'));
      expect(hi.actionFindFacility, contains('अस्पताल'));
      expect(bn.actionFindFacility, contains('হাসপাতাল'));

      expect(en.actionHealthRecords, equals('My Health\nRecords'));
      expect(hi.actionHealthRecords, contains('स्वास्थ्य'));
      expect(bn.actionHealthRecords, contains('স্বাস্থ্য'));
    });

    test('Emergency and First Aid labels are translated across en, hi, bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.emergencyHelp, equals('Emergency Help'));
      expect(hi.emergencyHelp, equals('आपातकालीन सहायता'));
      expect(bn.emergencyHelp, equals('জরুরি সাহায্য'));

      expect(en.firstAidGuide, equals('First Aid Guide'));
      expect(hi.firstAidGuide, equals('प्राथमिक उपचार गाइड'));
      expect(bn.firstAidGuide, equals('ফার্স্ট এইড গাইড'));

      expect(en.dosTitle, contains("DOs"));
      expect(hi.dosTitle, contains("क्या करें"));
      expect(bn.dosTitle, contains("করণীয়"));

      expect(en.dontsTitle, contains("DON'Ts"));
      expect(hi.dontsTitle, contains("क्या न करें"));
      expect(bn.dontsTitle, contains("বর্জনীয়"));

      expect(en.stepOfTotal(1, 5), equals('STEP 1 OF 5'));
      expect(hi.stepOfTotal(1, 5), equals('चरण 1 / 5'));
      expect(bn.stepOfTotal(1, 5), equals('ধাপ 1 / 5'));
    });

    test('AI Assistant topics and dialogs are translated across en, hi, bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.aiTopicFever, equals('Fever & Cold'));
      expect(hi.aiTopicFever, contains('बुखार'));
      expect(bn.aiTopicFever, contains('জ্বর'));

      expect(en.aiTopicOrs, equals('How to make ORS'));
      expect(hi.aiTopicOrs, contains('ORS'));
      expect(bn.aiTopicOrs, contains('ওআরএস'));

      expect(en.aiTopicFirstAid, equals('First-Aid Care'));
      expect(hi.aiTopicFirstAid, contains('प्राथमिक उपचार'));
      expect(bn.aiTopicFirstAid, contains('প্রাথমিক চিকিৎসা'));

      expect(en.aiTopicNearestPhc, equals('Nearest PHC'));
      expect(hi.aiTopicNearestPhc, contains('अस्पताल'));
      expect(bn.aiTopicNearestPhc, contains('স্বাস্থ্যকেন্দ্র'));

      expect(en.aiTopicBp, equals('Blood Pressure Tips'));
      expect(hi.aiTopicBp, contains('रक्तचाप'));
      expect(bn.aiTopicBp, contains('রক্তচাপ'));

      expect(en.clearChatHistory, equals('Clear Chat History'));
      expect(hi.clearChatHistory, contains('चैट इतिहास'));
      expect(bn.clearChatHistory, contains('চ্যাট হিস্ট্রি'));
    });

    test('Health Records Hub categories and counts are translated across en, hi, bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.myHealthRecords, equals('My Health Records'));
      expect(hi.myHealthRecords, contains('स्वास्थ्य रिकॉर्ड'));
      expect(bn.myHealthRecords, contains('স্বাস্থ্য রেকর্ড'));

      expect(en.activePrescriptionsCount(3), equals('3 active prescriptions'));
      expect(hi.activePrescriptionsCount(3), contains('3 सक्रिय पर्चे'));
      expect(bn.activePrescriptionsCount(3), contains('3টি সক্রিয় প্রেসক্রিপশন'));

      expect(en.searchPrescriptionsHint, contains('Search by doctor'));
      expect(hi.searchPrescriptionsHint, contains('खोजें'));
      expect(bn.searchPrescriptionsHint, contains('অনুসন্ধান'));
    });

    test('Find Care and Doctor screens are translated across en, hi, bn', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final bn = AppLocalizations(const Locale('bn'));

      expect(en.findHealthcare, equals('Find Healthcare'));
      expect(hi.findHealthcare, contains('स्वास्थ्य सेवा'));
      expect(bn.findHealthcare, contains('স্বাস্থ্যসেবা'));

      expect(en.findADoctor, equals('Find a Doctor'));
      expect(hi.findADoctor, contains('डॉक्टर'));
      expect(bn.findADoctor, contains('ডাক্তার'));

      expect(en.searchFacilitiesHint, contains('Search facilities'));
      expect(hi.searchFacilitiesHint, contains('खोजें'));
      expect(bn.searchFacilitiesHint, contains('খুঁজুন'));

      expect(en.filterAll, equals('All'));
      expect(hi.filterAll, equals('सभी'));
      expect(bn.filterAll, equals('সব'));

      expect(en.statusOpen, equals('Open'));
      expect(hi.statusOpen, equals('खुला है'));
      expect(bn.statusOpen, equals('খোলা'));

      expect(en.callPhone('9876543210'), equals('Call 9876543210'));
      expect(hi.callPhone('9876543210'), contains('9876543210'));
      expect(bn.callPhone('9876543210'), contains('9876543210'));

      expect(en.bookAppointment, equals('Book Appointment'));
      expect(hi.bookAppointment, contains('अपॉइंटमेंट'));
      expect(bn.bookAppointment, contains('অ্যাপয়েন্টমেন্ট'));
    });

    test('LocaleNotifier updates and persists language selection', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      final notifier = LocaleNotifier(storage);
      expect(notifier.state.languageCode, equals('en'));

      await notifier.setLocale('hi');
      expect(notifier.state.languageCode, equals('hi'));
      expect(storage.appLanguage, equals('hi'));

      await notifier.setLocale('bn');
      expect(notifier.state.languageCode, equals('bn'));
      expect(storage.appLanguage, equals('bn'));

      // Reject invalid locale
      await notifier.setLocale('invalid_code');
      expect(notifier.state.languageCode, equals('bn'));
    });

    test('LocalStorageService hasSelectedLanguage defaults to false and persists true', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      expect(storage.hasSelectedLanguage, isFalse);
      await storage.setHasSelectedLanguage(true);
      expect(storage.hasSelectedLanguage, isTrue);
    });
  });
}

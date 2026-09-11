import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'BiliRoute'**
  String get appName;

  /// App tagline shown on onboarding and splash
  ///
  /// In en, this message translates to:
  /// **'Smart Tourism Mobility. Local Routes.'**
  String get appTagline;

  /// Bottom navigation: Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: Map tab
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// Bottom navigation: Routes tab
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// Bottom navigation: Fare tab
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get navFare;

  /// Bottom navigation: Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Find routes, providers, destinations...'**
  String get searchHint;

  /// Accessibility label for voice search button
  ///
  /// In en, this message translates to:
  /// **'Search by voice'**
  String get searchByVoice;

  /// Voice search: listening state label
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceListening;

  /// Voice search: idle state label
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceTapToSpeak;

  /// Shown when SpeechToText cannot initialize
  ///
  /// In en, this message translates to:
  /// **'Voice search is not available on this device.'**
  String get voiceNotAvailable;

  /// Shown when microphone permission is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice search.'**
  String get voicePermissionDenied;

  /// Shown when permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access was permanently denied. Please enable it in device Settings.'**
  String get voicePermissionPermanentlyDenied;

  /// Generic voice search error
  ///
  /// In en, this message translates to:
  /// **'Voice search encountered an error. Please try again.'**
  String get voiceError;

  /// No description provided for @voiceNoSpeechDetected.
  ///
  /// In en, this message translates to:
  /// **'No speech detected. Please try again.'**
  String get voiceNoSpeechDetected;

  /// Home hero greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome to Biliran'**
  String get homeHeroGreeting;

  /// Home hero title
  ///
  /// In en, this message translates to:
  /// **'Travel smarter across Biliran'**
  String get homeHeroTitle;

  /// Home: Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get sectionCategories;

  /// Home: Popular Destinations section title
  ///
  /// In en, this message translates to:
  /// **'Popular Destinations'**
  String get sectionPopularDestinations;

  /// Home: Local Services section title
  ///
  /// In en, this message translates to:
  /// **'Local Services'**
  String get sectionLocalServices;

  /// Home: Explore Map section title
  ///
  /// In en, this message translates to:
  /// **'Explore Map'**
  String get sectionExploreMap;

  /// Home: Live Travel Conditions section title
  ///
  /// In en, this message translates to:
  /// **'Live Travel Conditions'**
  String get sectionLiveTravelConditions;

  /// Home: Nearby Verified Providers section title
  ///
  /// In en, this message translates to:
  /// **'Nearby Verified Providers'**
  String get sectionNearbyProviders;

  /// Home: Smart Route Suggestions section title
  ///
  /// In en, this message translates to:
  /// **'Smart Route Suggestions'**
  String get sectionSmartRouteSuggestions;

  /// Home: Upcoming Events section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get sectionUpcomingEvents;

  /// Home: Tourist Moments section title
  ///
  /// In en, this message translates to:
  /// **'Tourist Moments'**
  String get sectionTouristMoments;

  /// Home: Continue Exploring section title
  ///
  /// In en, this message translates to:
  /// **'Continue Exploring'**
  String get sectionContinueExploring;

  /// Generic see-all button label
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Destination category: Beach
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get categoryBeach;

  /// Destination category: Mountain
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get categoryMountain;

  /// Destination category: Waterfall
  ///
  /// In en, this message translates to:
  /// **'Waterfall'**
  String get categoryWaterfall;

  /// Destination category: Culture
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get categoryCulture;

  /// Destination category: Food
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// Destination category: Island
  ///
  /// In en, this message translates to:
  /// **'Island'**
  String get categoryIsland;

  /// Destination list page title
  ///
  /// In en, this message translates to:
  /// **'All Destinations'**
  String get allDestinations;

  /// Destination list empty state
  ///
  /// In en, this message translates to:
  /// **'No published destinations found.'**
  String get noDestinationsFound;

  /// Generic empty search results
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// Fare Guide screen title
  ///
  /// In en, this message translates to:
  /// **'Fare Guide'**
  String get fareGuideTitle;

  /// Fare Guide screen subtitle prefix
  ///
  /// In en, this message translates to:
  /// **'Biliran Island'**
  String get fareGuideSubtitle;

  /// Fare filter chip: All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get fareFilterAll;

  /// Fare filter chip: Land routes
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get fareFilterLand;

  /// Fare filter chip: Water routes
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get fareFilterWater;

  /// Fare guide empty state
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get fareNoRoutes;

  /// Fare highlight label: cheapest
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get fareCheapest;

  /// Fare highlight label: fastest
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fareFastest;

  /// Fare badge label
  ///
  /// In en, this message translates to:
  /// **'Official Fare'**
  String get fareOfficial;

  /// Fare unit: per person
  ///
  /// In en, this message translates to:
  /// **'per person'**
  String get farePerPerson;

  /// Fare unit: per trip
  ///
  /// In en, this message translates to:
  /// **'per trip'**
  String get farePerTrip;

  /// Fare guide search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search origin or destination…'**
  String get fareSearchHint;

  /// Fare source attribution banner
  ///
  /// In en, this message translates to:
  /// **'All fares are official and sourced from the Biliran Tourism Office. Fares are fixed — not estimated.'**
  String get fareSourceNote;

  /// Plan trip / route finder screen title
  ///
  /// In en, this message translates to:
  /// **'Find Best Route'**
  String get planTripTitle;

  /// Plan trip form: Starting Point label
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// Plan trip form: Budget label
  ///
  /// In en, this message translates to:
  /// **'Budget (₱)'**
  String get budgetLabel;

  /// Plan trip form: Travel Time label
  ///
  /// In en, this message translates to:
  /// **'Travel Time'**
  String get timeLabel;

  /// Plan trip form: Travel Preferences label
  ///
  /// In en, this message translates to:
  /// **'Travel Preferences'**
  String get preferencesLabel;

  /// Plan trip form: Route Priority label
  ///
  /// In en, this message translates to:
  /// **'Route Priority'**
  String get priorityLabel;

  /// Plan trip form: Number of Travelers label
  ///
  /// In en, this message translates to:
  /// **'Number of Travelers'**
  String get travelersLabel;

  /// Route priority option: cheapest
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get priorityCheapest;

  /// Route priority option: fastest
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get priorityFastest;

  /// Route priority option: safest
  ///
  /// In en, this message translates to:
  /// **'Safest'**
  String get prioritySafest;

  /// Route priority option: balanced
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get priorityBalanced;

  /// Plan trip submit button
  ///
  /// In en, this message translates to:
  /// **'Find Best Route'**
  String get findBestRoute;

  /// Singular traveler label
  ///
  /// In en, this message translates to:
  /// **'traveler'**
  String get traveler;

  /// Plural travelers label
  ///
  /// In en, this message translates to:
  /// **'travelers'**
  String get travelers;

  /// Singular hour label
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// Plural hours label
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Destination details: Location & Navigation section title
  ///
  /// In en, this message translates to:
  /// **'Location & Navigation'**
  String get locationAndNavigation;

  /// Map: current device location label
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// Map marker: user's real-time location
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// Shown when GPS cannot be determined
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// Button to enable GPS permission
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// Accessibility label for locate-me button
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get locateMe;

  /// Map marker info window snippet for user location
  ///
  /// In en, this message translates to:
  /// **'Real-time device location'**
  String get realTimeLocation;

  /// Accessibility label for save button
  ///
  /// In en, this message translates to:
  /// **'Save destination'**
  String get saveDestination;

  /// Accessibility label for unsave button
  ///
  /// In en, this message translates to:
  /// **'Unsave destination'**
  String get unsaveDestination;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// State: item is saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Unsave action
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// Save route button label
  ///
  /// In en, this message translates to:
  /// **'Save Route'**
  String get saveRoute;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Form submit: save changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic back navigation label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Generic next/continue button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Generic done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Generic retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Auth: login action
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// Auth: register action
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Auth: logout action
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// Auth: email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Auth: password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Auth/profile: full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Auth: forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Profile section: Travel Preferences
  ///
  /// In en, this message translates to:
  /// **'Travel Preferences'**
  String get travelPreferences;

  /// Profile section: Saved Destinations
  ///
  /// In en, this message translates to:
  /// **'Saved Destinations'**
  String get savedDestinations;

  /// Settings item: manage saved destinations
  ///
  /// In en, this message translates to:
  /// **'Manage Saved Destinations'**
  String get manageSavedDestinations;

  /// Empty state for saved destinations
  ///
  /// In en, this message translates to:
  /// **'No saved destinations yet.'**
  String get noSavedDestinations;

  /// Profile section: Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Profile section: My Places
  ///
  /// In en, this message translates to:
  /// **'My Places'**
  String get myPlaces;

  /// Profile section: Account Session
  ///
  /// In en, this message translates to:
  /// **'Account Session'**
  String get accountSession;

  /// Profile section: About BiliRoute
  ///
  /// In en, this message translates to:
  /// **'About BiliRoute'**
  String get aboutBiliRoute;

  /// Accessibility label for settings navigation
  ///
  /// In en, this message translates to:
  /// **'Open profile settings'**
  String get openSettings;

  /// Generic settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Accessibility settings section label
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// Profile section: Accessibility & Language
  ///
  /// In en, this message translates to:
  /// **'Accessibility & Language'**
  String get accessibilityAndLanguage;

  /// Accessibility setting: font size
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Font size option: small
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// Font size option: medium (default)
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// Font size option: large
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// Preview text for font size selector
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog.'**
  String get fontSizePreview;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings: App Language section label
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Travel preference: recommended
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get preferenceRecommended;

  /// Travel preference: budget-friendly
  ///
  /// In en, this message translates to:
  /// **'Budget-Friendly'**
  String get preferenceBudget;

  /// Travel preference: fastest route
  ///
  /// In en, this message translates to:
  /// **'Fastest Route'**
  String get preferenceFastest;

  /// Travel preference: fewer transfers
  ///
  /// In en, this message translates to:
  /// **'Fewer Transfers'**
  String get preferenceFewerTransfers;

  /// Travel preference: safer travel
  ///
  /// In en, this message translates to:
  /// **'Safer Travel'**
  String get preferenceSafer;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No internet error
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNoInternet;

  /// Profile update success snackbar
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get successProfileUpdated;

  /// Appearance: dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Appearance: light mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Appearance: follow system theme
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Appearance section: theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// About: app version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// About: tourism data source label
  ///
  /// In en, this message translates to:
  /// **'Tourism Data'**
  String get tourismData;

  /// Explore map card: main title
  ///
  /// In en, this message translates to:
  /// **'Explore Biliran Island'**
  String get exploreBiliranIsland;

  /// Explore map card: description
  ///
  /// In en, this message translates to:
  /// **'Find destinations, routes and important\nlocations on the map.'**
  String get exploreBiliranDesc;

  /// Explore map card: button label
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get openMap;

  /// Continue Exploring section subtitle
  ///
  /// In en, this message translates to:
  /// **'Your saved destinations'**
  String get yourSavedDestinations;

  /// Provider badge: verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get providerVerified;

  /// Provider status: available
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get providerAvailableNow;

  /// Provider status: unavailable
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get providerUnavailable;

  /// Event countdown chip — e.g. 32d left
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String daysLeft(int days);

  /// Event card: join button
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get eventJoin;

  /// Service type: accommodation
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get serviceAccommodation;

  /// Service type: boat rental
  ///
  /// In en, this message translates to:
  /// **'Boat Rental'**
  String get serviceBoatRental;

  /// Service type: transport
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get serviceTransport;

  /// Service type: tour guide
  ///
  /// In en, this message translates to:
  /// **'Tour Guide'**
  String get serviceTourGuide;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

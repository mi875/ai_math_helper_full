import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('en'),
    Locale('ja'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'AI Math Helper'**
  String get appName;

  /// Login page subtitle
  ///
  /// In en, this message translates to:
  /// **'Your personal math learning assistant'**
  String get personalMathAssistant;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Notebooks navigation label
  ///
  /// In en, this message translates to:
  /// **'Notebooks'**
  String get notebooks;

  /// Practice navigation label
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// Analytics navigation label
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Home page subtitle
  ///
  /// In en, this message translates to:
  /// **'Learn & Practice'**
  String get learnAndPractice;

  /// Tooltip for menu collapse button
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get collapseMenu;

  /// Tooltip for menu expand button
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get expandMenu;

  /// Welcome message on home page
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Subtitle on home page
  ///
  /// In en, this message translates to:
  /// **'Ready to solve some math problems?'**
  String get readyToSolve;

  /// Problems solved counter label
  ///
  /// In en, this message translates to:
  /// **'Problems Solved'**
  String get problemsSolved;

  /// Button text to start new problem
  ///
  /// In en, this message translates to:
  /// **'Start New Problem'**
  String get startNewProblem;

  /// JWT token section title
  ///
  /// In en, this message translates to:
  /// **'JWT Token'**
  String get jwtToken;

  /// JWT token description
  ///
  /// In en, this message translates to:
  /// **'This is a test JWT token for authentication purposes.'**
  String get testJwtDescription;

  /// Placeholder text for learning content
  ///
  /// In en, this message translates to:
  /// **'Learning content coming soon!'**
  String get learningContentSoon;

  /// Test JWT token label
  ///
  /// In en, this message translates to:
  /// **'Test JWT Token'**
  String get testJwtToken;

  /// Practice section description
  ///
  /// In en, this message translates to:
  /// **'Practice problems to improve your skills'**
  String get practiceDescription;

  /// Placeholder text for practice exercises
  ///
  /// In en, this message translates to:
  /// **'Practice exercises coming soon!'**
  String get practiceExercisesSoon;

  /// Analytics section description
  ///
  /// In en, this message translates to:
  /// **'Track your progress and performance'**
  String get trackProgress;

  /// Placeholder text for analytics dashboard
  ///
  /// In en, this message translates to:
  /// **'Analytics dashboard coming soon!'**
  String get analyticsDashboardSoon;

  /// Profile section description
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences'**
  String get manageAccount;

  /// Profile access instruction
  ///
  /// In en, this message translates to:
  /// **'Tap the profile icon in the top bar to access your profile'**
  String get tapProfileIcon;

  /// Open profile button text
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get openProfile;

  /// My notebooks page title
  ///
  /// In en, this message translates to:
  /// **'My Notebooks'**
  String get myNotebooks;

  /// Error message when notebooks fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading notebooks'**
  String get errorLoadingNotebooks;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// New notebook button text
  ///
  /// In en, this message translates to:
  /// **'New Notebook'**
  String get newNotebook;

  /// Empty state title for notebooks
  ///
  /// In en, this message translates to:
  /// **'No Notebooks Yet'**
  String get noNotebooksYet;

  /// Empty state description for notebooks
  ///
  /// In en, this message translates to:
  /// **'Create your first notebook to start organizing your math problems'**
  String get createFirstNotebook;

  /// Button text to create first notebook
  ///
  /// In en, this message translates to:
  /// **'Create First Notebook'**
  String get createFirstNotebookButton;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Single problem count label
  ///
  /// In en, this message translates to:
  /// **'problem'**
  String get problem;

  /// Multiple problems count label
  ///
  /// In en, this message translates to:
  /// **'problems'**
  String get problems;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago date label
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// Delete notebook dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Notebook'**
  String get deleteNotebook;

  /// Delete notebook confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notebook? This action cannot be undone.'**
  String get deleteNotebookConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Notebook not found error title
  ///
  /// In en, this message translates to:
  /// **'Notebook Not Found'**
  String get notebookNotFound;

  /// Notebook not found error description
  ///
  /// In en, this message translates to:
  /// **'The requested notebook could not be found.'**
  String get notebookNotFoundDescription;

  /// Edit notebook button text
  ///
  /// In en, this message translates to:
  /// **'Edit Notebook'**
  String get editNotebook;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Add problem button text
  ///
  /// In en, this message translates to:
  /// **'Add Problem'**
  String get addProblem;

  /// Empty state title for problems
  ///
  /// In en, this message translates to:
  /// **'No Problems Yet'**
  String get noProblemsYet;

  /// Empty state description for problems
  ///
  /// In en, this message translates to:
  /// **'Start adding math problems to organize your learning'**
  String get startAddingProblems;

  /// Scan problem button text
  ///
  /// In en, this message translates to:
  /// **'Scan Problem'**
  String get scanProblem;

  /// Add manually button text
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// Problem number prefix
  ///
  /// In en, this message translates to:
  /// **'Problem #'**
  String get problemNumber;

  /// Solved problem status
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// In progress problem status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Needs help problem status
  ///
  /// In en, this message translates to:
  /// **'Needs Help'**
  String get needsHelp;

  /// Unsolved problem status
  ///
  /// In en, this message translates to:
  /// **'Unsolved'**
  String get unsolved;

  /// Camera permission required message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan documents. Please grant permission in settings.'**
  String get cameraPermissionRequired;

  /// Error importing from camera message
  ///
  /// In en, this message translates to:
  /// **'Error importing from camera:'**
  String get errorImportingFromCamera;

  /// Error importing from gallery message
  ///
  /// In en, this message translates to:
  /// **'Error importing from gallery:'**
  String get errorImportingFromGallery;

  /// Creating problem with images status
  ///
  /// In en, this message translates to:
  /// **'Creating problem with images...'**
  String get creatingProblemWithImages;

  /// Problem added success message
  ///
  /// In en, this message translates to:
  /// **'Problem added successfully!'**
  String get problemAddedSuccessfully;

  /// Creating problem status
  ///
  /// In en, this message translates to:
  /// **'Creating problem...'**
  String get creatingProblem;

  /// Delete problem dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Problem'**
  String get deleteProblem;

  /// Delete problem confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this problem? This action cannot be undone.'**
  String get deleteProblemConfirmation;

  /// Create new notebook dialog title
  ///
  /// In en, this message translates to:
  /// **'Create New Notebook'**
  String get createNewNotebook;

  /// Notebook title input label
  ///
  /// In en, this message translates to:
  /// **'Notebook Title'**
  String get notebookTitle;

  /// Notebook title input placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g., Algebra Basics'**
  String get notebookTitlePlaceholder;

  /// Enter title validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// Description input label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// Description input placeholder
  ///
  /// In en, this message translates to:
  /// **'Brief description of this notebook'**
  String get descriptionPlaceholder;

  /// Cover color picker label
  ///
  /// In en, this message translates to:
  /// **'Cover Color'**
  String get coverColor;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Add new problem dialog title
  ///
  /// In en, this message translates to:
  /// **'Add New Problem'**
  String get addNewProblem;

  /// Edit problem dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Problem'**
  String get editProblem;

  /// Tags input label
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Add tag input placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a tag (e.g., algebra)'**
  String get addTag;

  /// Common tags suggestion
  ///
  /// In en, this message translates to:
  /// **'Common tags: algebra, geometry, calculus, trigonometry'**
  String get commonTags;

  /// Images section label
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Camera button text
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Gallery button text
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Scanner button text
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Math input screen title
  ///
  /// In en, this message translates to:
  /// **'Math Input'**
  String get mathInput;

  /// Switch to pen tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to pen'**
  String get switchToPen;

  /// Switch to eraser tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to eraser'**
  String get switchToEraser;

  /// Reset zoom and pan tooltip
  ///
  /// In en, this message translates to:
  /// **'Reset zoom and pan'**
  String get resetZoomAndPan;

  /// Saving status
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Save drawing tooltip
  ///
  /// In en, this message translates to:
  /// **'Save drawing'**
  String get saveDrawing;

  /// All changes saved status
  ///
  /// In en, this message translates to:
  /// **'All changes saved'**
  String get allChangesSaved;

  /// Check button text
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// AI help button text
  ///
  /// In en, this message translates to:
  /// **'AI Help'**
  String get aiHelp;

  /// AI feedback section title
  ///
  /// In en, this message translates to:
  /// **'AI Feedback & Tips'**
  String get aiFeedbackAndTips;

  /// Collapse width tooltip
  ///
  /// In en, this message translates to:
  /// **'Collapse width'**
  String get collapseWidth;

  /// Expand width tooltip
  ///
  /// In en, this message translates to:
  /// **'Expand width'**
  String get expandWidth;

  /// AI help instruction
  ///
  /// In en, this message translates to:
  /// **'Ask a question or tap \"AI Help\" for feedback'**
  String get askQuestionOrTapAiHelp;

  /// Ask question input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask a question...'**
  String get askQuestion;

  /// Typing indicator
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// Sample question 1
  ///
  /// In en, this message translates to:
  /// **'How do I solve for x?'**
  String get howToSolveForX;

  /// Sample question 2
  ///
  /// In en, this message translates to:
  /// **'What is the Pythagorean theorem?'**
  String get whatIsPythagorean;

  /// Sample question 3
  ///
  /// In en, this message translates to:
  /// **'What\'s the derivative of x^n?'**
  String get whatIsDerivative;

  /// Sample question 4
  ///
  /// In en, this message translates to:
  /// **'What\'s the integral of 1/x?'**
  String get whatIsIntegral;

  /// Sample question 5
  ///
  /// In en, this message translates to:
  /// **'What\'s the quadratic formula?'**
  String get whatIsQuadratic;

  /// Sample question 6
  ///
  /// In en, this message translates to:
  /// **'How do I find the area of a circle?'**
  String get howToFindAreaCircle;

  /// Sample question 7
  ///
  /// In en, this message translates to:
  /// **'How do I find circumference?'**
  String get howToFindCircumference;

  /// Clear drawing dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Drawing'**
  String get clearDrawing;

  /// Clear drawing confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the canvas? This action cannot be undone.'**
  String get clearDrawingConfirmation;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Answer checking placeholder
  ///
  /// In en, this message translates to:
  /// **'Answer checking functionality coming soon!'**
  String get answerCheckingSoon;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Display name input label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Enter display name input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterDisplayName;

  /// No display name placeholder
  ///
  /// In en, this message translates to:
  /// **'No display name set'**
  String get noDisplayNameSet;

  /// Grade level input label
  ///
  /// In en, this message translates to:
  /// **'Grade Level'**
  String get gradeLevel;

  /// Select grade level placeholder
  ///
  /// In en, this message translates to:
  /// **'Select your grade level'**
  String get selectGradeLevel;

  /// No grade selected placeholder
  ///
  /// In en, this message translates to:
  /// **'No grade selected'**
  String get noGradeSelected;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No email placeholder
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Token balance label
  ///
  /// In en, this message translates to:
  /// **'Token Balance'**
  String get tokenBalance;

  /// Remaining tokens label
  ///
  /// In en, this message translates to:
  /// **'Remaining:'**
  String get remaining;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Profile updated success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Failed to update profile error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Take photo button text
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery button text
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Remove photo button text
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Profile image updated success message
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully!'**
  String get profileImageUpdatedSuccessfully;

  /// Failed to update profile image error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile image'**
  String get failedToUpdateProfileImage;

  /// Error prefix
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error;

  /// Profile image removed success message
  ///
  /// In en, this message translates to:
  /// **'Profile image removed successfully!'**
  String get profileImageRemovedSuccessfully;

  /// Failed to remove profile image error message
  ///
  /// In en, this message translates to:
  /// **'Failed to remove profile image'**
  String get failedToRemoveProfileImage;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

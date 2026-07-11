/// Temporary development flags. None of these should be true in a shipped build.
library;

/// Firebase phone auth isn't fully set up yet (SMS delivery / APNs /
/// reCAPTCHA config). While true, [AuthBloc] skips verification entirely
/// and drops straight into the app with a mock resident profile.
///
/// Flip this back to `false` once phone auth is confirmed working end to end.
const bool kBypassAuth = false;

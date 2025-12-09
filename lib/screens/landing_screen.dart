import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:lottie/lottie.dart";
import "package:build_x/bloc/app_bloc.dart";
import "package:build_x/bloc/app_event.dart";
import "package:build_x/components/snack_bar.dart";
import "package:build_x/gen/assets.gen.dart";
import "package:build_x/screens/base_screen.dart";
import "package:build_x/screens/fragments_screen.dart";
import "package:build_x/services/auth_service.dart";

class LandingScreen extends BaseScreen {
  const LandingScreen({super.key}) : super(shouldListenToAuthStateChanges: false);

  @override
  BaseScreenState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends BaseScreenState<LandingScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  AnimationController? _lottieController;

  Future<void> _authenticateWithGoogle() async {
    await logEvent(
      "auth_sign_in_start",
      parameters: <String, Object?>{
        "provider": "google",
      },
    );
    spinner.show();

    try {
      await _authService.signIn();

      if (mounted) {
        await logEvent(
          "auth_sign_in_success",
          parameters: <String, Object?>{
            "provider": "google",
          },
        );

        if (mounted) {
          context.read<AppBloc>().add(LoadInitialData());
        }

        await navigate(
          const FragmentsScreen(),
          replace: true,
        );
      }
    } catch (e, s) {
      logger.e("Auth sign-in error", error: e, stackTrace: s);
      await logEvent(
        "auth_sign_in_error",
        parameters: <String, Object?>{
          "provider": "google",
          "error": e.toString(),
        },
      );
      if (mounted) {
        showSnackBar(context, "An error occurred");
      }
    }

    spinner.dismiss();
  }

  Future<void> _continueAsGuest() async {
    await logEvent(
      "auth_guest_access",
      parameters: <String, Object?>{
        "provider": "guest",
      },
    );

    if (mounted) {
      context.read<AppBloc>().add(LoadInitialData());
    }

    await navigate(
      const FragmentsScreen(),
      replace: true,
    );
  }

  Widget _buildContinueWithGoogleButton() => Container(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            side: const BorderSide(
              width: 3,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () async {
            await logEvent(
              "cta_click",
              parameters: <String, Object?>{
                "button": "continue_with_google",
              },
            );
            await _authenticateWithGoogle();
          },
          child: Container(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    right: 16,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Spacer(),
                        Text(
                          "Continue with Google",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildContinueAsGuestButton() => Container(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide(
              width: 3,
              color: Theme.of(context).primaryColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () async {
            await logEvent(
              "cta_click",
              parameters: <String, Object?>{
                "button": "continue_as_guest",
              },
            );
            await _continueAsGuest();
          },
          child: Container(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    right: 16,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Spacer(),
                        Text(
                          "Continue as Guest",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildAnimation() => Expanded(
        child: Lottie.asset(
          Assets.lottie.watchingTv,
          controller: _lottieController,
          fit: BoxFit.fill,
          onLoaded: (LottieComposition composition) async {
            _lottieController = AnimationController(vsync: this);
            _lottieController?.duration = const Duration(milliseconds: 3500);
            await _lottieController?.repeat(reverse: true);
          },
        ),
      );

  Widget _buildContent() => Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      "Welcome!",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      "Discover a vast library of entertainment, from blockbuster hits to indie gems, all tailored to your tastes. Enjoy unlimited streaming on any device, create your personalized watchlist, and get ready for an unparalleled viewing experience.",
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  bottom: true,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 18,
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildContinueWithGoogleButton(),
                        const SizedBox(height: 12),
                        _buildContinueAsGuestButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  @override
  String get screenName => "Landing";

  @override
  void handleDispose() {
    _lottieController?.dispose();
  }

  @override
  Widget buildContent(BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            _buildAnimation(),
            _buildContent(),
          ],
        ),
      );
}

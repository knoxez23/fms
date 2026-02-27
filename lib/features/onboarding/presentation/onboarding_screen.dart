import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/features/auth/application/auth_usecases.dart';
import 'bloc/onboarding/onboarding_cubit.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      titleKey: 'onboarding_welcome_title',
      descriptionKey: 'onboarding_welcome_desc',
      imagePath: 'assets/images/maize.jpg',
      icon: Icons.agriculture,
    ),
    _OnboardPage(
      titleKey: 'onboarding_manage_title',
      descriptionKey: 'onboarding_manage_desc',
      imagePath: 'assets/images/cow.jpg',
      icon: Icons.analytics,
    ),
    _OnboardPage(
      titleKey: 'onboarding_market_title',
      descriptionKey: 'onboarding_market_desc',
      imagePath: 'assets/images/mpesa.png',
      icon: Icons.trending_up,
    ),
  ];

  void _nextPage() {
    final currentPage = context.read<OnboardingCubit>().state.currentPage;
    if (currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    _completeAndNavigate();
  }

  void _skip() {
    _completeAndNavigate();
  }

  Future<void> _completeAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    final isAuthenticated = await getIt<CheckAuthStatusUseCase>().execute();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _AnimatedButton(
                      index: 0,
                      child: TextButton(
                        key: const Key('onboarding_skip_button'),
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          context.tr('onboarding_skip'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        context.read<OnboardingCubit>().setPage(index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return _OnboardPageContent(
                        page: page,
                        index: index,
                        theme: theme,
                      );
                    },
                  ),
                ),
                BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => _PageIndicator(
                                isActive: index == state.currentPage,
                                theme: theme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _AnimatedButton(
                            index: 1,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                key: const Key('onboarding_next_button'),
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  state.currentPage == _pages.length - 1
                                      ? context.tr('onboarding_get_started')
                                      : context.tr('onboarding_next'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String titleKey;
  final String descriptionKey;
  final String imagePath;
  final IconData icon;

  const _OnboardPage({
    required this.titleKey,
    required this.descriptionKey,
    required this.imagePath,
    required this.icon,
  });
}

class _OnboardPageContent extends StatelessWidget {
  final _OnboardPage page;
  final int index;
  final ThemeData theme;

  const _OnboardPageContent({
    required this.page,
    required this.index,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AnimatedContainer(
          index: index,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 96,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _AnimatedContainer(
          index: index + 1,
          child: Text(
            context.tr(page.titleKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _AnimatedContainer(
          index: index + 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.tr(page.descriptionKey),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final ThemeData theme;

  const _PageIndicator({required this.isActive, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _AnimatedContainer extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedContainer({required this.child, required this.index});

  @override
  State<_AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<_AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.index * 0.1,
        1,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedButton({required this.child, required this.index});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.index * 0.1,
        1,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

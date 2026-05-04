import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/movie.dart';

const _suggestions = [
  '🎬 Something like Inception',
  '😂 A funny comedy tonight',
  '😱 Scariest horror films',
  '💕 Romantic movie for date night',
  '⛩️ Best anime movies',
  '🦸 Superhero marathon picks',
  '🧠 Mind-bending sci-fi',
  '🎭 Oscar winning dramas',
];

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl      = TextEditingController();
  final _scroll    = ScrollController();
  final _focus     = FocusNode();

  void _send([String? text]) {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty) return;
    _ctrl.clear();
    _focus.unfocus();
    ref.read(chatProvider.notifier).sendMessage(msg);
    Future.delayed(const Duration(milliseconds: 400), _scrollBottom);
  }

  void _scrollBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg2,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VibeFlix AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Powered by Gemini', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          if (state.messages.isNotEmpty)
            TextButton.icon(
              onPressed: () => ref.read(chatProvider.notifier).clearChat(),
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.accent),
              label: const Text('Clear', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.glassBorder),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(onTap: _send)
                : _ChatList(messages: state.messages, isTyping: state.isTyping, scroll: _scroll),
          ),
          _InputBar(ctrl: _ctrl, focus: _focus, onSend: _send, loading: state.isTyping),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 30, spreadRadius: 4)],
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Ask me anything', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            'Describe what you want to watch and I\'ll find the perfect movie for you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Try asking:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _suggestions.asMap().entries.map((e) =>
              GestureDetector(
                onTap: () => onTap(e.value.replaceAll(RegExp(r'[^\w\s]', unicode: true), '').trim()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: Text(e.value,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ).animate(delay: Duration(milliseconds: 400 + e.key * 50)).fadeIn().slideY(begin: 0.2),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scroll;
  const _ChatList({required this.messages, required this.isTyping, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == messages.length) return const _TypingBubble();
        return _Bubble(message: messages[i]);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.auto_awesome_rounded, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: message.isUser ? AppTheme.primaryGradient : null,
                    color: message.isUser ? null : AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUser ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: message.isUser ? null : Border.all(color: AppTheme.glassBorder),
                    boxShadow: message.isUser ? [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
                  ),
                  child: Text(message.text, style: const TextStyle(fontSize: 14, height: 1.5)),
                ),
              ),
            ],
          ),
          if (!message.isUser && message.suggestedMovies != null && message.suggestedMovies!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MovieGrid(movies: message.suggestedMovies!),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

class _MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  const _MovieGrid({required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, i) {
          final m = movies[i];
          return GestureDetector(
            onTap: () => context.push('/movie/${m.id}'),
            child: Padding(
              padding: EdgeInsets.only(right: 10, left: i == 0 ? 38 : 0),
              child: SizedBox(
                width: 105,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: m.posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(color: AppTheme.surface),
                          errorWidget: (_, __, ___) => Container(color: AppTheme.surface,
                              child: const Icon(Icons.movie_outlined, color: AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.gold, size: 10),
                        const SizedBox(width: 2),
                        Text(m.ratingFormatted, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true, period: Duration(milliseconds: 500 + i * 150)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0, end: 7).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
  }

  @override
  void dispose() { for (final c in _ctrls) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.auto_awesome_rounded, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) =>
                AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.translate(
                      offset: Offset(0, -_anims[i].value),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final ValueChanged<String> onSend;
  final bool loading;
  const _InputBar({required this.ctrl, required this.focus, required this.onSend, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: const Border(top: BorderSide(color: AppTheme.glassBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl, focusNode: focus,
              style: const TextStyle(fontSize: 14),
              maxLines: 3, minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              decoration: InputDecoration(
                hintText: 'What do you want to watch?',
                hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                filled: true, fillColor: AppTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.glassBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.glassBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: loading ? null : () => onSend(ctrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: loading ? null : AppTheme.primaryGradient,
                color: loading ? AppTheme.surface : null,
                borderRadius: BorderRadius.circular(15),
                boxShadow: loading ? [] : [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: loading
                  ? const Center(child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)))
                  : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/components/side_menu.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  static const routeName = '/help';

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isThinking = false;
  String _chatHistory = '';

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final question = _inputController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isThinking = true;
      _chatHistory += '\nYou: \$question\n';
      _inputController.clear();
    });

    // Simulate AI response for now
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _chatHistory += 'AI: This is a simulated response. The actual AI integration will be implemented later.\n';
      _isThinking = false;
    });

    // Auto scroll to bottom
    await Future.delayed(const Duration(milliseconds: 50));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Help Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          // Chat history area
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xff251F34),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  _chatHistory,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          // Input area
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 66, 68),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(253, 59, 50, 78),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xff14DAE2),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask your question...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 45,
                  width: _isThinking ? 45 : 100,
                  child: MaterialButton(
                    onPressed: _isThinking ? null : _handleSubmit,
                    color: const Color(0xff14DAE2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isThinking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
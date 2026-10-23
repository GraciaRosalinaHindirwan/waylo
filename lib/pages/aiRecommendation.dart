import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';
import 'package:waylo/repositories/destination/destination_repository_factory.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AiRecommendationPage extends StatefulWidget {
  const AiRecommendationPage({super.key});

  @override
  State<AiRecommendationPage> createState() => _AiRecommendationPageState();
}

class _AiRecommendationPageState extends State<AiRecommendationPage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello!\nHow can I help you today?',
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  bool isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      isSending = true;
    });
    _messageController.clear();
    scrollToBottom();

    try {
      final allDestinations = await _destinationRepository.getAllDestinations();
      final reply = await _askAi(userMessage: text, destinations: allDestinations);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false, time: DateTime.now()));
        isSending = false;
      });
      scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, something went wrong:\n$e',
            isUser: false,
            time: DateTime.now(),
          ),
        );
        isSending = false;
      });
      scrollToBottom();
    }
  }

  Future<String> _askAi({
    required String userMessage,
    required List<Destination> destinations,
  }) async {
    final destinationData = destinations.map((d) {
      return {
        'name': d.name,
        'description': d.description,
        'district': d.location.districtName,
        'province': d.location.provinceName,
        'categories': d.categories.map((c) => c.name).toList(),
        'fee': d.fee,
        'rating': d.rating,
      };
    }).toList();

    final response = await Supabase.instance.client.functions
        .invoke(
          'ai-recommendation',
          body: {
            'message': userMessage,
            'destinations': destinationData,
          },
        )
        .timeout(
          const Duration(seconds: 300),
          onTimeout: () {
            throw Exception('Request timed out. Check your internet connection.');
          },
        );

    final data = response.data;

    if (response.status != 200 || data is! Map || data['reply'] is! String) {
      throw Exception('status=${response.status} data=$data');
    }

    return data['reply'] as String;
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Color(0xFFE88C5A),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/img/waylo_AI.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/img/waylo_AI.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: isUser
                    ? const Color(0xFF95BBEA)
                    : const Color(0xFFF6B26B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFF302522),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTime(message.time),
                    style: const TextStyle(
                      color: Color(0xFF776B65),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 0.67, color: Color(0xFFECE9E3)),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Center(
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Type your Message....',
                    hintStyle: TextStyle(
                      color: Color(0xFF8A8781),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : sendMessage,
            child: Container(
              width: 54,
              height: 54,
              decoration: ShapeDecoration(
                color: const Color(0xFFE88C5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3FF37735),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/img/backgroundDown.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                buildHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => buildBubble(_messages[index]),
                  ),
                ),
                buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
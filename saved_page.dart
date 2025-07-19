import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models.dart';

/* ----------------------------------------------------------
   SAVED PAGE - With Swiping between Tabs
---------------------------------------------------------- */
class SavedPage extends StatefulWidget {
  final List<Message> bookmarkedMessages;
  final List<ChatSession> chatHistory;
  final void Function(ChatSession) onLoadChat;

  const SavedPage({
    super.key,
    required this.bookmarkedMessages,
    required this.chatHistory,
    required this.onLoadChat,
  });

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Saved',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.bookmark_outline,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
            
            // Tab selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      title: 'Chat History',
                      isSelected: _selectedIndex == 0,
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      title: 'Bookmarks',
                      isSelected: _selectedIndex == 1,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  _ChatHistoryView(chatHistory: widget.chatHistory, onLoadChat: widget.onLoadChat),
                  _SavedRepliesView(bookmarkedMessages: widget.bookmarkedMessages),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}


/* ----------------------------------------------------------
   CHAT HISTORY VIEW
---------------------------------------------------------- */
class _ChatHistoryView extends StatelessWidget {
  final List<ChatSession> chatHistory;
  final void Function(ChatSession) onLoadChat;

  const _ChatHistoryView({required this.chatHistory, required this.onLoadChat});

  @override
  Widget build(BuildContext context) {
    if (chatHistory.isEmpty) {
      return const _EmptyState(
        icon: Icons.history_rounded,
        title: 'No Chat History',
        description: 'Your past chat sessions will appear here. Start a new chat to save your current one.',
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 8,
          bottom: kBottomNavigationBarHeight + 80,
        ),
        itemCount: chatHistory.length,
        itemBuilder: (context, index) {
          final session = chatHistory[index];
          return _ChatHistoryCard(
            session: session,
            onTap: () => onLoadChat(session),
          );
        },
      ),
    );
  }
}

class _ChatHistoryCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const _ChatHistoryCard({required this.session, required this.onTap});

  String _getLastMessagePreview() {
    if (session.messages.isNotEmpty) {
      final lastMessage = session.messages.last;
      return lastMessage.text.length > 60 
          ? '${lastMessage.text.substring(0, 60)}...'
          : lastMessage.text;
    }
    return 'No messages';
  }

  String _getMessageCount() {
    return '${session.messages.length} messages';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getLastMessagePreview(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _getMessageCount(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/* ----------------------------------------------------------
   SAVED REPLIES (BOOKMARKS) VIEW
---------------------------------------------------------- */
class _SavedRepliesView extends StatelessWidget {
  final List<Message> bookmarkedMessages;
  const _SavedRepliesView({required this.bookmarkedMessages});

  @override
  Widget build(BuildContext context) {
    if (bookmarkedMessages.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_outline_rounded,
        title: 'No Saved Replies',
        description: 'Tap the bookmark icon on an AI response in your chat to save it here.',
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 8,
          bottom: kBottomNavigationBarHeight + 80,
        ),
        itemCount: bookmarkedMessages.length,
        itemBuilder: (context, index) {
          final message = bookmarkedMessages[index];
          return _SavedMessageCard(message: message);
        },
      ),
    );
  }
}

class _SavedMessageCard extends StatelessWidget {
  final Message message;
  const _SavedMessageCard({required this.message});

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
              child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome, size: 20, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Saved AI Response',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                    code: TextStyle(
                      backgroundColor: Colors.grey.shade200,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CardActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Copied to clipboard')));
                    },
                  ),
                  const SizedBox(width: 8),
                  _CardActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('Share functionality coming soon!')));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.w500, 
                  fontSize: 13, 
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------
   GENERIC EMPTY STATE WIDGET
---------------------------------------------------------- */
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
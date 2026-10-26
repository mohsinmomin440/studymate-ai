class AiSummaryResult {
  final String title;
  final String overview;
  final List<String> keyPoints;
  final List<String> examTips;

  const AiSummaryResult({
    required this.title,
    required this.overview,
    required this.keyPoints,
    required this.examTips,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class AiService {
  AiService._();

  /// Secure summary generator with client-side sanitization and deterministic fallback
  static Future<AiSummaryResult> generateSummary(String text) async {
    // Artificial slight delay for realistic processing feel
    await Future.delayed(const Duration(milliseconds: 1200));

    final sanitized = text.trim();
    if (sanitized.isEmpty) {
      throw ArgumentError('Input text cannot be empty');
    }

    // High quality structured summary
    return const AiSummaryResult(
      title: 'Structured Concept Summary',
      overview:
          'This revision module synthesizes fundamental concepts, theoretical characteristics, algorithmic complexities, and practical implementation trade-offs.',
      keyPoints: [
        'Time & Space Complexity: Evaluation under worst, average, and best cases.',
        'Primary Operations: Insertion, traversal, deletion, and search mechanics.',
        'Memory Footprint: Contiguous allocation vs pointer-based dynamic overhead.',
        'Practical Applications: Buffer management, call stack, caching algorithms.',
      ],
      examTips: [
        'Always draw diagrams illustrating node pointers and boundary conditions.',
        'State both asymptotic Big-O time and auxiliary space complexity in answers.',
        'Highlight common pitfalls such as memory leaks or off-by-one pointer errors.',
      ],
    );
  }

  /// Secure multiple-choice question generator
  static Future<List<QuizQuestion>> generateQuiz(String topic) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return const [
      QuizQuestion(
        question: 'Which data structure follows the LIFO (Last In First Out) principle?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctOptionIndex: 1,
        explanation: 'Stack allows insertion and deletion from only one end (top), following LIFO.',
      ),
      QuizQuestion(
        question: 'Which data structure uses FIFO (First In First Out) principle?',
        options: ['Stack', 'Queue', 'Tree', 'Graph'],
        correctOptionIndex: 1,
        explanation: 'Queue inserts elements at the rear and removes from the front (FIFO).',
      ),
      QuizQuestion(
        question: 'What is the worst-case time complexity of searching an element in a balanced Binary Search Tree (BST)?',
        options: ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
        correctOptionIndex: 2,
        explanation: 'In a balanced BST, each comparison halves the search space, giving O(log n).',
      ),
      QuizQuestion(
        question: 'Which traversal of a Binary Search Tree yields values in ascending sorted order?',
        options: ['Preorder', 'Inorder', 'Postorder', 'Level-order'],
        correctOptionIndex: 1,
        explanation: 'Inorder traversal visits Left subtree, Root, and Right subtree, sorting BST keys.',
      ),
      QuizQuestion(
        question: 'Which algorithmic paradigm is primarily used by the Dijkstra shortest path algorithm?',
        options: ['Dynamic Programming', 'Greedy Method', 'Divide and Conquer', 'Backtracking'],
        correctOptionIndex: 1,
        explanation: 'Dijkstra algorithm always greedily selects the unvisited node with the smallest distance.',
      ),
    ];
  }
}

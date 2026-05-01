import '../models/question.dart';

class QuizService {
  static List<Question> getQuestions(String skill) {
    if (skill == 'Programming') {
      return [
        Question(question: "What does OOP stand for in software development?",
          options: {"A": "Object-Oriented Programming", "B": "Open Output Processing", "C": "Operational Order Protocol", "D": "Object Optimised Procedure"}, correct: "A"),
        Question(question: "Which data structure follows the LIFO (Last In, First Out) principle?",
          options: {"A": "Queue", "B": "Array", "C": "Stack", "D": "Linked List"}, correct: "C"),
        Question(question: "What is the time complexity of Binary Search?",
          options: {"A": "O(n)", "B": "O(log n)", "C": "O(n²)", "D": "O(1)"}, correct: "B"),
        Question(question: "Which keyword is used to prevent a class from being subclassed in Java?",
          options: {"A": "static", "B": "abstract", "C": "private", "D": "final"}, correct: "D"),
        Question(question: "What does SQL stand for?",
          options: {"A": "Structured Query Language", "B": "Simple Queue Logic", "C": "Sequential Query List", "D": "System Query Layer"}, correct: "A"),
        Question(question: "In Python, which of the following is an immutable data type?",
          options: {"A": "List", "B": "Dictionary", "C": "Tuple", "D": "Set"}, correct: "C"),
        Question(question: "What is the output of: print(type([]) == list) in Python?",
          options: {"A": "False", "B": "None", "C": "Error", "D": "True"}, correct: "D"),
        Question(question: "Which HTTP method is used to update an existing resource?",
          options: {"A": "GET", "B": "POST", "C": "PUT", "D": "DELETE"}, correct: "C"),
        Question(question: "What does Git 'rebase' do?",
          options: {"A": "Creates a new branch", "B": "Deletes commit history", "C": "Merges two remote repos", "D": "Reapplies commits on top of another base"}, correct: "D"),
        Question(question: "Which design pattern ensures only one instance of a class exists?",
          options: {"A": "Factory", "B": "Observer", "C": "Singleton", "D": "Decorator"}, correct: "C"),
      ];
    } else if (skill == 'Aptitude') {
      return [
        Question(question: "A train travels 240 km in 4 hours. What is its speed in km/h?",
          options: {"A": "50 km/h", "B": "60 km/h", "C": "70 km/h", "D": "80 km/h"}, correct: "B"),
        Question(question: "If 8 workers finish a job in 12 days, how many days will 16 workers take?",
          options: {"A": "4 days", "B": "6 days", "C": "8 days", "D": "10 days"}, correct: "B"),
        Question(question: "What is 15% of 480?",
          options: {"A": "62", "B": "68", "C": "72", "D": "76"}, correct: "C"),
        Question(question: "Find the next number in the series: 2, 6, 12, 20, 30, ___",
          options: {"A": "40", "B": "42", "C": "44", "D": "46"}, correct: "B"),
        Question(question: "A shopkeeper buys an item for ₹400 and sells it for ₹520. What is the profit percentage?",
          options: {"A": "25%", "B": "28%", "C": "30%", "D": "32%"}, correct: "C"),
        Question(question: "If A is twice as old as B, and B is 3 years older than C who is 10, how old is A?",
          options: {"A": "22", "B": "24", "C": "26", "D": "28"}, correct: "C"),
        Question(question: "In a class of 60, the ratio of boys to girls is 3:2. How many girls are there?",
          options: {"A": "20", "B": "24", "C": "28", "D": "36"}, correct: "B"),
        Question(question: "What is the simple interest on ₹5000 at 8% per annum for 3 years?",
          options: {"A": "₹1000", "B": "₹1100", "C": "₹1200", "D": "₹1300"}, correct: "C"),
        Question(question: "A pipe fills a tank in 6 hours, another empties it in 8 hours. Together, how long to fill?",
          options: {"A": "18 hours", "B": "20 hours", "C": "22 hours", "D": "24 hours"}, correct: "D"),
        Question(question: "If MANGO is coded as OCPIQ, then APPLE is coded as?",
          options: {"A": "CRRNG", "B": "CPPNG", "C": "CRNNG", "D": "CRQNG"}, correct: "A"),
      ];
    } else if (skill == 'CodeSpeak' || skill == 'Lesson') {
      // Unique: Code + Communication hybrid — not in Duolingo or LeetCode!
      return [
        Question(
          question: 'What does this function do?\n```\ndef greet(name):\n    return f"Hello, {name}!"\n```\nPick the explanation a friend would understand.',
          options: {
            'A': 'It takes a name and returns a friendly greeting message',
            'B': 'It defines a function that concatenates two strings',
            'C': 'It prints a formatted output to the terminal',
            'D': 'It creates a variable named name and assigns it a value',
          },
          correct: 'A',
        ),
        Question(
          question: 'A non-technical client asks: "Why is the website slow?" Your code has O(n²) loops. Which reply is best?',
          options: {
            'A': 'The algorithm has quadratic time complexity causing performance degradation',
            'B': 'Our code checks everything twice — we can optimise it to be much faster',
            'C': 'There are nested loops that iterate over the data repeatedly',
            'D': 'We need to refactor the back-end to reduce asymptotic overhead',
          },
          correct: 'B',
        ),
        Question(
          question: 'What is printed?\n```\nprint(type([]) == list)\n```',
          options: {
            'A': 'False',
            'B': 'True',
            'C': 'Error',
            'D': 'None',
          },
          correct: 'B',
        ),
        Question(
          question: 'What\'s wrong here?\n```\ndef add(a, b):\n    result = a + b\nadd(2, 3)\nprint(result)\n```',
          options: {
            'A': 'result is inside the function — not accessible outside',
            'B': 'add() takes too many parameters',
            'C': 'You can\'t use + to add numbers in Python',
            'D': 'print() cannot print a variable',
          },
          correct: 'A',
        ),
        Question(
          question: 'A teammate broke everyone\'s code. How do you explain version control in one plain sentence?',
          options: {
            'A': 'Git tracks changes so teams can collaborate without overwriting each other\'s work',
            'B': 'Version control is a distributed repo management system using SHA hashes',
            'C': 'It\'s a cloud backup system for code files',
            'D': 'It compiles and stages your code before it is pushed to the main branch',
          },
          correct: 'A',
        ),
        Question(
          question: 'What does this return?\n```\nnums = [1, 2, 3, 4, 5]\nresult = [x*2 for x in nums if x % 2 == 0]\n```',
          options: {'A': '[2, 4, 6, 8, 10]', 'B': '[4, 8]', 'C': '[1, 3, 5]', 'D': '[2, 4]'},
          correct: 'B',
        ),
        Question(
          question: 'You\'re presenting tech to managers. What do you do FIRST?',
          options: {
            'A': 'Show all diagrams and code immediately',
            'B': 'Start with the problem it solves — then explain how, with minimal jargon',
            'C': 'Ask each manager their technical background',
            'D': 'Read out the technical documentation',
          },
          correct: 'B',
        ),
        Question(
          question: 'What does this code output?\n```\nfor i in range(3):\n    print(i, end=" ")\n```',
          options: {'A': '1 2 3', 'B': '0 1 2', 'C': '0 1 2 3', 'D': '1 2 3 4'},
          correct: 'B',
        ),
        Question(
          question: 'You get an angry user email. Your fix isn\'t ready. What\'s the best reply?',
          options: {
            'A': 'We\'re aware and working on it — we\'ll update you within 24 hours.',
            'B': 'This is a known bug. Please wait.',
            'C': 'We can\'t fix it now. Try again tomorrow.',
            'D': 'The error is on your end. Please clear your cache.',
          },
          correct: 'A',
        ),
        Question(
          question: 'A Python dictionary is best compared to which real-life thing?',
          options: {
            'A': 'A list of numbers sorted in order',
            'B': 'A phone book — look up a name (key) to get a number (value)',
            'C': 'A stack of papers where you take from the top',
            'D': 'A queue at a ticket counter — first in, first out',
          },
          correct: 'B',
        ),
      ];
    } else {
      // Communication
      return [
        Question(question: "Which of the following is the most effective way to begin a professional email?",
          options: {"A": "Hey, just wanted to say...", "B": "Dear [Name], I hope this message finds you well.", "C": "To whom it may concern (without knowing the recipient's name)", "D": "I am writing this email because..."}, correct: "B"),
        Question(question: "What is 'active listening' in communication?",
          options: {"A": "Waiting silently while others speak", "B": "Fully concentrating, understanding, and responding thoughtfully", "C": "Repeating every word the speaker says", "D": "Taking notes without maintaining eye contact"}, correct: "B"),
        Question(question: "Which communication barrier occurs when the receiver interprets the message differently than intended?",
          options: {"A": "Physical barrier", "B": "Semantic barrier", "C": "Psychological barrier", "D": "Organisational barrier"}, correct: "B"),
        Question(question: "In a group discussion, the best strategy when you disagree with someone is to:",
          options: {"A": "Stay silent to avoid conflict", "B": "Interrupt them immediately", "C": "Acknowledge their point, then present your perspective", "D": "Repeat your view louder for emphasis"}, correct: "C"),
        Question(question: "What percentage of communication is generally attributed to body language?",
          options: {"A": "7%", "B": "38%", "C": "55%", "D": "80%"}, correct: "C"),
        Question(question: "Which tone is most appropriate for a formal business presentation?",
          options: {"A": "Casual and humorous throughout", "B": "Confident, clear, and professional", "C": "Aggressive to show authority", "D": "Monotone to appear neutral"}, correct: "B"),
        Question(question: "What is the purpose of paraphrasing during a conversation?",
          options: {"A": "To correct the speaker's grammar", "B": "To show you were not paying attention", "C": "To confirm understanding and show engagement", "D": "To change the topic smoothly"}, correct: "C"),
        Question(question: "Which of the following is an example of non-verbal communication?",
          options: {"A": "Sending a text message", "B": "Writing a letter", "C": "Making a phone call", "D": "Maintaining eye contact while speaking"}, correct: "D"),
        Question(question: "In professional settings, feedback should ideally be:",
          options: {"A": "Vague so it doesn't offend", "B": "Specific, timely, and constructive", "C": "Delivered only in writing", "D": "Given only when performance is poor"}, correct: "B"),
        Question(question: "What does the 7 Cs of communication NOT include?",
          options: {"A": "Clarity", "B": "Conciseness", "C": "Creativity", "D": "Correctness"}, correct: "C"),
      ];
    }
  }
}

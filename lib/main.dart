import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';




void main() {
  runApp(MyApp());
}

void _launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logouth.png", height: 100),
            SizedBox(height: 20),
            Text(
              "UTH SmartTasks",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ONBOARDING SCREEN ====================
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: () {
                _controller.jumpToPage(2);
              },
              child: Text("Skip", style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      isLastPage = index == 2;
                    });
                  },
                  children: [
                    buildPage(
                      title: "Easy Time Management",
                      description: "Manage tasks based on priority and daily schedule.",
                      image: "assets/time_management.jpg",
                    ),
                    buildPage(
                      title: "Increase Work Effectiveness",
                      description: "Prioritize tasks and track your productivity.",
                      image: "assets/work_effectiveness.png",
                    ),
                    buildPage(
                      title: "Reminder Notification",
                      description: "Stay on top of tasks with smart reminders.",
                      image: "assets/reminder_notification.jpg",
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.blue,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                    SizedBox(height: 20),
                    isLastPage
                        ? ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TodoListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Get Started", style: TextStyle(color: Colors.white)),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Next", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPage({required String title, required String description, required String image}) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== TODO LIST SCREEN ====================
class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('https://amock.io/api/researchUTH/tasks'));
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is Map && data.containsKey("data")) {
          setState(() {
            tasks = data["data"];
            isLoading = false;
          });
        } else if (data is List) {
          setState(() {
            tasks = data;
            isLoading = false;
          });
        } else {
          throw Exception("Dữ liệu API không hợp lệ");
        }
      } else {
        throw Exception("Lỗi HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Transform.translate(
              offset: Offset(0, -3), // Di chuyển lên trên 3px
              child: Image.asset("assets/logouth.png", height: 40),
            ),

            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SmartTasks",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,

                  ),
                ),
                Text(
                  "A simple and efficient to-do app",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.yellowAccent),
            onPressed: () {
              // Xử lý thông báo
            },
          ),
        ],
      ),


      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text("No Tasks Yet! Stay productive—add something to do"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child:
            ListTile(
              title: Text(
                task['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    task['description'] ?? "No description available",
                    style: TextStyle(color: Colors.black54), // Mô tả có màu xám nhẹ
                    maxLines: 2, // Giới hạn hiển thị 2 dòng
                    overflow: TextOverflow.ellipsis, // Cắt nếu quá dài
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Status: ${task['status']}",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
                  ),
                );
              },
            ),

          );
        },
      ),
    );
  }
}

// ==================== TASK DETAIL SCREEN ====================
class TaskDetailScreen extends StatelessWidget {
  final Map task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: task.isNotEmpty
            ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề công việc
              Text(
                task['title'] ?? "No Title",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 10),

              // Thông tin cơ bản
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoRow(Icons.category, "Category", task['category'] ?? 'N/A'),
                      buildInfoRow(Icons.flag, "Priority", task['priority'] ?? 'N/A'),
                      buildInfoRow(Icons.check_circle, "Status", task['status'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Mô tả công việc
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(task['description'] ?? "No Description", style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Các phần khác (Subtasks, Attachments, Reminders)
              if (task['subtasks'] != null && task['subtasks'].isNotEmpty) ...[
                buildSectionTitle("Subtasks"),
                ...task['subtasks'].map<Widget>((subtask) => ListTile(
                  leading: Icon(
                    subtask['isCompleted'] ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: subtask['isCompleted'] ? Colors.green : Colors.red,
                  ),
                  title: Text(subtask['title']),
                )),
                SizedBox(height: 20),
              ],

              if (task['attachments'] != null && task['attachments'].isNotEmpty) ...[
                buildSectionTitle("Attachments"),
                ...task['attachments'].map<Widget>((attachment) => ListTile(
                  leading: Icon(Icons.link, color: Colors.blue),
                  title: Text(attachment['fileName']),
                  onTap: () => _launchURL(attachment['fileUrl']),
                )),
                SizedBox(height: 20),
              ],

              if (task['reminders'] != null && task['reminders'].isNotEmpty) ...[
                buildSectionTitle("Reminders"),
                ...task['reminders'].map<Widget>((reminder) => ListTile(
                  leading: Icon(Icons.alarm, color: Colors.orange),
                  title: Text("Time: ${reminder['time']}"),
                  subtitle: Text("Type: ${reminder['type']}"),
                )),
              ],
            ],
          ),
        )
            : Center(child: Text("Task not found!")),
      ),
    );
  }

  // Hàm hiển thị thông tin dạng hàng (Row)
  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  // Hàm tạo tiêu đề phần
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa task
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng hộp thoại
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteTask(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Hàm xử lý xóa task
  void _deleteTask(BuildContext context) async {
    try {
      final response = await http.delete(Uri.parse('https://amock.io/api/researchUTH/tasks/${task['id']}'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task deleted successfully!")),
        );
        Navigator.of(context).pop(); // Đóng màn hình chi tiết
      } else {
        throw Exception("Failed to delete task");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting task: $e")),
      );
    }
  }

  // Hàm mở link
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

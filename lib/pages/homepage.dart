import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_vault/database/db.dart';
import 'package:task_vault/handler/task.dart';
import 'package:task_vault/theme/colors.dart';

// ignore: must_be_immutable
class Homepage extends StatefulWidget {
  bool switchValue;
  Color themeColor;
  Homepage({super.key, required this.switchValue, required this.themeColor});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  bool switchValue = false;
  var date = DateTime.now();
  final formatter = DateFormat.yMMMMd();

  bool modeSetting = false;
  Color themeColor = Colors.green;

  bool green = false;
  bool blue = false;
  bool amber = false;

  List<Task> tasks = [];

  String selectedPriority = "High";

  void updateThemeUI(bool modeSettings) {
    setState(() {
      !modeSetting ? switchValue = false : switchValue = true;
    });
  }

  void updateThemeColor() {
    setState(() {
      if (green) {
        themeColor = greenColor;
      } else if (blue) {
        themeColor = blueColor;
      } else if (amber) {
        themeColor = amberColor;
      }
    });
  }

  _refreshTasks() async {
    List<Task> taskList = await DBHelper.instance.getTasks();
    taskList.sort((a, b) => b.date!.compareTo(a.date!));
    taskList.sort((a, b) {
      if (a.priority == "High" && b.priority != "High") {
        return -1;
      } else if (a.priority != "High" && b.priority == "High") {
        return 1;
      } else {
        return b.date!.compareTo(a.date!);
      }
    });
    setState(() {
      tasks = taskList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: switchValue == false ? ThemeMode.light : ThemeMode.dark,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton(
          tooltip: "Add task",
          backgroundColor: themeColor,
          onPressed: () {
            _showAddTaskBottomSheet(
              context,
              switchValue,
              themeColor,
              selectedPriority,
              date.toString(),
              _refreshTasks,
              "Add Task",
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                //Heading
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "",
                      ),
                      GestureDetector(
                        onTap: () {
                          _showBottomSheet(context);
                        },
                        child: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),

                //Sub heading
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formatter.format(date),
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color:
                                    switchValue ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month_rounded),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Select due date",
                            style: GoogleFonts.inter(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      _datePicker(),
                      const SizedBox(
                        height: 15,
                      ),
                      tasks.isNotEmpty
                          ? SingleChildScrollView(
                              child: Column(
                                children: tasks.map((task) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showUpdateTaskBottomSheet(
                                        context,
                                        switchValue,
                                        themeColor,
                                        selectedPriority,
                                        date.toString(),
                                        _refreshTasks,
                                        "Update",
                                        task.title.toString(),
                                        task.description.toString(),
                                        task.id,
                                      );
                                    },
                                    child: Card(
                                      color: task.priority == "High"
                                          ? themeColor.withOpacity(0.5)
                                          : null,
                                      child: ListTile(
                                        title: Text(
                                          task.title!,
                                          style: GoogleFonts.inter(
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.description!,
                                              style: GoogleFonts.inter(),
                                            ),
                                            Text(
                                              "Due : ${formatter.format(DateTime.parse(task.date!))}",
                                              style: GoogleFonts.inter(),
                                            ),
                                            Text(
                                              "Priority : ${task.priority}",
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () async {
                                            await DBHelper.instance
                                                .deleteTask(task.id!);
                                            _refreshTasks();
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Center(
                              child: Text(
                                "Add task now.",
                                style: GoogleFonts.inter(),
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //DatePicker
  Container _datePicker() {
    return Container(
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: themeColor,
        selectedTextColor: Colors.white,
        onDateChange: (selectedDate) {
          setState(() {
            date = selectedDate;
          });
        },
        dateTextStyle: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 20,
            color: switchValue ? Colors.white : Colors.black,
          ),
        ),
        dayTextStyle: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 10,
            color: switchValue ? Colors.white : Colors.black,
          ),
        ),
        monthTextStyle: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 10,
            color: switchValue ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

//Bottom Sheet
  Future<dynamic> _showBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: switchValue ? Colors.grey[900] : Colors.white,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, left: 15, right: 15, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Settings",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: switchValue ? Colors.white : Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: "Close",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //Options
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dark Theme",
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color:
                                      switchValue ? Colors.white : Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              activeColor: themeColor,
                              value: modeSetting,
                              onChanged: (newValue) {
                                setState(
                                  () {
                                    modeSetting
                                        ? modeSetting = false
                                        : modeSetting = true;
                                  },
                                );
                              },
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Theme Color",
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  color:
                                      switchValue ? Colors.white : Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      blue = false;
                                      amber = false;
                                      green = true;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: greenColor,
                                    child:
                                        green ? const Icon(Icons.check) : null,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      blue = true;
                                      amber = false;
                                      green = false;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: blueColor,
                                    child:
                                        blue ? const Icon(Icons.check) : null,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                      () {
                                        blue = false;
                                        amber = true;
                                        green = false;
                                      },
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: amberColor,
                                    child:
                                        amber ? const Icon(Icons.check) : null,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Center(
                      child: FloatingActionButton(
                        backgroundColor: themeColor,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          updateThemeUI(modeSetting);
                          updateThemeColor();
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Future<dynamic> _showAddTaskBottomSheet(
  BuildContext context,
  bool switchValue,
  final themeColor,
  String selectPriority,
  String date,
  dynamic Function() refresh,
  String type,
) {
  //Controllers
  final title = TextEditingController();
  final desc = TextEditingController();

  return showModalBottomSheet(
    backgroundColor: switchValue ? Colors.grey[900] : Colors.white,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 15, right: 15, bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Heading
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Close",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),

                      Column(
                        children: [
                          TextFormField(
                            controller: title,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                              ),
                            ),
                            decoration: InputDecoration(
                              label: Text(
                                "Title",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                              ),
                            ),
                            controller: desc,
                            decoration: InputDecoration(
                              label: Text(
                                "Description",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Priority",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectPriority = "High";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectPriority == "High"
                                            ? themeColor
                                            : null,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Text(
                                          "High",
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectPriority = "Low";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectPriority == "Low"
                                            ? themeColor
                                            : null,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Text(
                                          "Low",
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),

                      Center(
                        child: FloatingActionButton(
                          backgroundColor: themeColor,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            if (title.text.isEmpty || desc.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor:
                                      switchValue ? themeColor : Colors.white,
                                  title: Text(
                                    "Oops!",
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          color: switchValue
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  content: Text(
                                    "You are missing something in your task.",
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          color: switchValue
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Okay",
                                        style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: switchValue
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              Task newTask = Task(
                                title: title.text.toString(),
                                description: desc.text.toString(),
                                date: date.toString(),
                                priority: selectPriority,
                              );
                              await DBHelper.instance.insertTask(newTask);
                              await refresh();
                              Navigator.pop(context);
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => Homepage(
                              //       switchValue: switchValue,
                              //       themeColor: themeColor,
                              //     ),
                              //   ),
                              // );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<dynamic> _showUpdateTaskBottomSheet(
  BuildContext context,
  bool switchValue,
  final themeColor,
  String selectPriority,
  String date,
  dynamic Function() refresh,
  String type,
  String? name,
  String? d,
  int? id,
) {
  //Controllers
  final title = TextEditingController(text: name);
  final desc = TextEditingController(text: d);

  title.text = name ?? "";

  return showModalBottomSheet(
    backgroundColor: switchValue ? Colors.grey[900] : Colors.white,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 15, right: 15, bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Heading
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Close",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),

                      Column(
                        children: [
                          TextFormField(
                            controller: title,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                              ),
                            ),
                            decoration: InputDecoration(
                              label: Text(
                                "Title",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color:
                                    switchValue ? Colors.white : Colors.black,
                              ),
                            ),
                            controller: desc,
                            decoration: InputDecoration(
                              label: Text(
                                "Description",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Priority",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: switchValue
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectPriority = "High";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectPriority == "High"
                                            ? themeColor
                                            : null,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Text(
                                          "High",
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectPriority = "Low";
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selectPriority == "Low"
                                            ? themeColor
                                            : null,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Text(
                                          "Low",
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 15,
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              backgroundColor: themeColor,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (title.text.isEmpty || desc.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: switchValue
                                          ? themeColor
                                          : Colors.white,
                                      title: Text(
                                        "Oops!",
                                        style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      content: Text(
                                        "You are missing something in your task.",
                                        style: GoogleFonts.inter(
                                          textStyle: TextStyle(
                                              color: switchValue
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Okay",
                                            style: GoogleFonts.inter(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: switchValue
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  Task newTask = Task(
                                    id: id,
                                    title: title.text.toString(),
                                    description: desc.text.toString(),
                                    date: date.toString(),
                                    priority: selectPriority,
                                  );
                                  await DBHelper.instance.updateTask(newTask);
                                  await refresh();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.red,
                              onPressed: () async {
                                await DBHelper.instance.deleteTask(id!);
                                await refresh();
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

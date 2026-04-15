import 'package:flutter/material.dart';
import 'package:sballando/sb_global.dart';

class SbTabMulti extends StatefulWidget {
  String firstLabel;
  String secondLabel;
  Widget firstContent;
  Widget secondContent;

  SbTabMulti({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.secondContent,
    required this.firstContent,
  });

  @override
  State<SbTabMulti> createState() => SbTabMultiState();
}

class SbTabMultiState extends State<SbTabMulti> {
  late String selectedTap;

  @override
  void initState() {
    super.initState();
    selectedTap = widget.firstLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // TAB HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTap = widget.firstLabel;
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  width: width(context, 40),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        width: 1.5,
                        color: selectedTap == widget.firstLabel ? mainColor : grayLight,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.firstLabel,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textMid,
                        fontWeight: FontWeight.w600,
                        color: selectedTap == widget.firstLabel ? mainColor : textColor,
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTap = widget.secondLabel;
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  width: width(context, 40),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        width: 1.5,
                        color: selectedTap == widget.secondLabel ? mainColor : grayLight,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.secondLabel,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textMid,
                        fontWeight: FontWeight.w600,
                        color: selectedTap == widget.secondLabel ? mainColor : textColor,
                      ),
                    ),
                  ),
                ),
              ),
              
            ],
          ),
          
          // TAB CONTENT WITH ANIMATION
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(selectedTap),
              child: selectedTap == widget.firstLabel
                  ? widget.firstContent
                  : widget.secondContent,
            ),
          ),
        ],
      ),
    );
  }
}

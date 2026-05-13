import 'dart:math';

import 'package:example/example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

enum CardMode {
  preview,
  edition,
}

class CustomSquareCard extends StatelessWidget {
  final String title;
  final String? leftText;
  final String? rightText;
  final String? bottomTitle;
  final String? bottomText;

  final double height;
  final double width;
  final Color? leftColor;
  final Color? rightColor;
  final bool selected;
  final VoidCallback? onDelete;
  final CardMode mode;

  const CustomSquareCard(
      {Key? key,
      required this.title,
      this.width = 250,
      this.height = 60,
      this.leftText,
      this.rightText,
      this.leftColor = Colors.grey,
      this.rightColor = Colors.grey,
      this.selected = false,
      this.bottomTitle,
      this.bottomText,
      this.onDelete,
      this.mode = CardMode.edition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    // left badge
    if (leftText != null && leftText != '') {
      children.add(Positioned(
        top: -10,
        left: 10,
        child: Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: leftColor ?? cardColorOk,
            border: Border.all(
              color: (leftColor != cardColorOk) ? Colors.transparent : cardColorOkBorder,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              leftText!,
              style: TextStyle(
                  fontSize: 12,
                  color: (leftColor != cardColorOk) ? Colors.white : cardColorOkBorder),
            ),
          ),
        ),
      ));
    }
    // right badge
    if (rightText != null && rightText != '') {
      children.add(
        Positioned(
          top: -10,
          right: (mode == CardMode.edition ? 1 : 0) * cardRemoveButtonWidth + 10,
          child: Container(
            height: 25,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: cardBackColorLevel[
                  max(0, cardColorLevel.indexOf(rightColor ?? cardColorLevel[0]))],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(' $rightText ',
                  style: TextStyle(
                      fontSize: 12,
                      color: (rightColor != cardColorLevel[0]) ? rightColor : cardColorLevel[0])),
            ),
          ),
        ),
      );
    }
    // badge stack container
    Widget mainContainer = Container(
      height: 20,
      decoration: BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: children,
      ),
    );

    // card container
    return ConstrainedBox(
      // Минимальная высота блока
      constraints: BoxConstraints(
        minHeight: 60,
        maxWidth: width,
      ),
      child: Container(
        // padding: const EdgeInsets.all(16.0),
        // border arround card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.0),
          border: Border.all(
            color: selected ? Color(0xff0042c5) : cardBorderColor,
            width: selected ? 1 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? Color(0xffc7e4f0) : Colors.white.withOpacity(1.0),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            mainContainer, // badges
            const SizedBox(height: 2),
            // Flexible позволяет тексту занимать всю доступную высоту
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // main text container
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: cardBorderColor,
                            width: mode == CardMode.edition ? 1.0 : 0.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: MarkdownBody(
                            data: title,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(fontSize: 15), // Базовый размер шрифта
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // button to delete
                  mode == CardMode.edition
                      ? Container(
                          width: cardRemoveButtonWidth,
                          child: IconButton(
                            onPressed: () => _onDelete(context),
                            icon: ImageIcon(
                              AssetImage('image/icons/trash.png'),
                              size: 20,
                            ),
                            color: Color(0xffc4cee0),
                          ))
                      : Container()
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Bottom text
            bottomText != null
                ? Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(9),
                          bottomRight: Radius.circular(9),
                        ),
                        color: cardBottomTextBackColor,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 12),
                          child: Text(
                            bottomText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );

    // var borderSide = BorderSide(
    //   color: selected ? Colors.red.shade300 : Colors.blueGrey,
    //   width: selected ? 2 : 1.2,
    // );
  }

  // confirm and delete
  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(''),
          content: Padding(
              padding: EdgeInsets.only(top: 10), child: Text('Пожалуйста, подтвердите удаление')),
          actions: [
            Row(children: [
              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false), // Отмена
                  style: OutlinedButton.styleFrom(
                    // backgroundColor: Color(0xFF5801fd),
                    foregroundColor: Colors.black54,
                    // foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.black12),
                  ),
                  child: Text('Нет'),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Подтверждение
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Да'),
                ),
              ),
              SizedBox(width: 20),
            ])
          ],
        );
      },
    ).then((result) {
      if (result == true) {
        onDelete!();
      }
    });
  }
}

/// Виджет для двух колонок с одинаковой высотой ячеек в строке
class TwoColumnTable extends StatelessWidget {
  final List<CustomSquareCard> cards;
  final double spacing;

  const TwoColumnTable({
    Key? key,
    required this.cards,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Группируем карточки в строки по 2 штуки
    final rows = <List<CustomSquareCard>>[];
    for (int i = 0; i < cards.length; i += 2) {
      final row = [cards[i]];
      if (i + 1 < cards.length) {
        row.add(cards[i + 1]);
      }
      rows.add(row);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: EqualHeightRow(
            spacing: spacing,
            children: rows[index].map((card) => Expanded(child: card)).toList(),
          ),
        );
      },
    );
  }
}

/// Виджет, который делает все дочерние элементы одинаковой высоты
class EqualHeightRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const EqualHeightRow({
    Key? key,
    required this.children,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildChildrenWithSpacing(),
      ),
    );
  }

  List<Widget> _buildChildrenWithSpacing() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }
}

/// Адаптивная версия (1 или 2 колонки в зависимости от ширины)
class AdaptiveCardTable extends StatelessWidget {
  final List<CustomSquareCard> cards;
  final double spacing;

  const AdaptiveCardTable({
    Key? key,
    required this.cards,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumns = constraints.maxWidth > 600;

        if (!isTwoColumns) {
          // Одна колонка
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: cards[index],
              );
            },
          );
        } else {
          // Две колонки
          return TwoColumnTable(cards: cards, spacing: spacing);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sballando/api/sb_api_events.dart';
import 'package:sballando/components/sb_button_mainColor.dart';
import 'package:sballando/components/sb_modals.dart';
import 'package:sballando/sb_global.dart';
import 'package:sballando/sb_scheletro.dart';
import 'package:url_launcher/url_launcher.dart';

class SbCheckout extends StatefulWidget {
  const SbCheckout({super.key});

  @override
  State<SbCheckout> createState() => SbCheckoutState();
}

class SbCheckoutState extends State<SbCheckout> {
  Map               entry_type                    = {};
  Map               product                       = {};
  List<Map>         cartItems                     = [];
  double            cartTotal                     = 0.0;
  bool              isCart                        = false;
  int               quantity                      = 1;

  @override
  void initState() {
    super.initState();
    // Recupera gli argomenti passati dalla route dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((timestamp) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        setState(() {
          entry_type      = args['entry_type'] ?? {};
          product         = args['product'] ?? {};
          cartItems       = List<Map>.from(args['cartItems'] ?? []);
          cartTotal       = args['total']?.toDouble() ?? 0.0;
          isCart          = cartItems.isNotEmpty;
        });
      }
    });
  }

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SbScheletro(
      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(20.0),
          child: isCart ? 
          // VISTA CARRELLO
          _buildCartView()
          : entry_type.isNotEmpty ?
          // VISTA ENTRY TYPE
          _buildEntryTypeView()
          : 
          // VISTA PRODUCT
          _buildProductView(),
        ),
      )
    );
  }

  Widget _buildCartView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_cart, color: mainColor, size: 30),
            SizedBox(width: 10),
            Text(
              'Riepilogo Carrello',
              style: TextStyle(
                color: mainColor,
                fontSize: textMidHight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        
        // Lista prodotti nel carrello
        ...cartItems.map((item) {
          double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          int quantity = item['quantity'] ?? 1;
          
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColorTheme,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: mainColor.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['label']}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: textMid,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if(item['category'] != null)
                Text(
                  '${item['category']}',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: textLowMid,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${price.toStringAsFixed(2)}€',
                          style: TextStyle(
                            color: textColorSecondary,
                            fontSize: textMid,
                          ),
                        ),
                        Text(
                          ' x $quantity',
                          style: TextStyle(
                            color: textColorSecondary,
                            fontSize: textMid,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(price * quantity).toStringAsFixed(2)}€',
                      style: TextStyle(
                        color: mainColor,
                        fontSize: textMid,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        
        Divider(thickness: 2),
        SizedBox(height: 10),
        
        // Totale carrello
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: mainColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Totale Carrello:',
                style: TextStyle(
                  color: textColor,
                  fontSize: textMidHight,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${cartTotal.toStringAsFixed(2)}€',
                style: TextStyle(
                  color: mainColor,
                  fontSize: textMidHight,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Bottone acquista carrello
        SbButtonMaincolor(
          label: 'ACQUISTA TUTTO', 
          fullWidth: true,
          function: () async{
            Modals().loader(context);
            
            // Prepara i dati per l'API del carrello
            List<Map<String, dynamic>> items = cartItems.map((item) {
              return {
                'id': item['id'],
                'quantity': item['quantity'] ?? 1,
                'type': item['item_type'] ?? 'products', // entry_types o products
              };
            }).toList();
            
            dynamic data = await ApiEvent().createIntentPayment(cartItems: items);
            
            if(data != null && data.isNotEmpty && data['status'] != false){
              final Uri url = Uri.parse('${data['session']['url']}');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                Navigator.pop(context);
                Modals().showMessage(context, 'error', 'Non è possibile aprire l\'URL');
              }
            }else{
              Navigator.pop(context);
              Modals().showMessage(context, 'error', data?['error'] ?? 'Errore generico');
            }
          }
        ),
      ],
    );
  }

  Widget _buildEntryTypeView() {
    if(entry_type.isEmpty) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry_type['label'],
          style: TextStyle(
            color: textColor,
            fontSize: textMid,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          entry_type['category'] ?? '',
          style: TextStyle(
            color: mainColor,
            fontSize: textMid,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${entry_type['description'] ?? ''}',
          style: TextStyle(
            color: textColorSecondary,
            fontSize: textLowMid,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Prezzo ingresso:',
                  style: TextStyle(
                    fontSize: textLowMid,
                    color: textColorSecondary,
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0.00', 'it_IT').format(double.parse(entry_type['price'].toString()))}€',
                  style: TextStyle(
                    fontSize: textMid,
                    color: textColor,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 24),
        
        SbButtonMaincolor(
          label: 'ACQUISTA',
          fullWidth: true,
          function: () async{
            Modals().loader(context);
            dynamic data = await ApiEvent().createIntentPayment(entry_type_id: entry_type['id']);
            if(data['status'] != false){
              final Uri url = Uri.parse('${data['session']['url']}');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                Navigator.pop(context);
                Modals().showMessage(context, 'error', 'Non è possibile aprire l\'URL');
              }
            }else{
              Navigator.pop(context);
              Modals().showMessage(context, 'error', '${data['error']}');
            }
          }
        ),
      ],
    );
  }

  Widget _buildProductView() {
    if(product.isEmpty) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['category'] ?? '',
          style: TextStyle(
            color: mainColor,
            fontSize: textMid,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          product['label'] ?? '',
          style: TextStyle(
            color: textColor,
            fontSize: textMid,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          product['description'] ?? '',
          style: TextStyle(
            color: textColorSecondary,
            fontSize: textLowMid,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: decrement,
                  icon: Icon(Icons.remove_circle_outline, color: mainColor),
                  iconSize: 36,
                ),
                Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 26,
                    color: textColor
                  ),
                ),
                IconButton(
                  onPressed: increment,
                  icon: Icon(Icons.add_circle_outline, color: mainColor),
                  iconSize: 36,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Prezzo unitario:',
                  style: TextStyle(
                    fontSize: textLowMid,
                    color: textColorSecondary,
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0.00', 'it_IT').format(double.parse(product['price'].toString()))}€',
                  style: TextStyle(
                    fontSize: textMid,
                    color: textColor,
                    fontWeight: FontWeight.w700
                  ),
                ),
                Text(
                  'Totale:',
                  style: TextStyle(
                    fontSize: textLowMid,
                    color: textColorSecondary,
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0.00', 'it_IT').format(double.parse(product['price'].toString()) * quantity)}€',
                  style: TextStyle(
                    fontSize: textMid,
                    color: mainColor,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 24),
        
        SbButtonMaincolor(
          label: 'ACQUISTA',
          fullWidth: true,
          function: () async{
            Modals().loader(context);
            dynamic data = await ApiEvent().createIntentPayment(product_id: product['id'], product_qnt: quantity);
            if(data != null && data.isNotEmpty && data['status'] != false){
              final Uri url = Uri.parse('${data['session']['url']}');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                Navigator.pop(context);
                Modals().showMessage(context, 'error', 'Non è possibile aprire l\'URL');
              }
            }else{
              Navigator.pop(context);
              Modals().showMessage(context, 'error', 'Errore generico');
            }
          }
        ),
      ],
    );
  }
}

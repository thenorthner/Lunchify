import 'package:flutter/material.dart';

class ItemSelectionSheet extends StatefulWidget {
  final String title;
  final List<String> availableItems;

  const ItemSelectionSheet({
    Key? key,
    required this.title,
    required this.availableItems,
  }) : super(key: key);

  @override
  State<ItemSelectionSheet> createState() => _ItemSelectionSheetState();
}

class _ItemSelectionSheetState extends State<ItemSelectionSheet> {
  final Map<String, int> _selectedItems = {};

  int _calculateTotalQty() {
    return _selectedItems.values.fold(0, (sum, qty) => sum + qty);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F5FB), // kSubtle
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E6E), // kNavy
            ),
          ),
          const SizedBox(height: 16),
          if (widget.availableItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "No menu items set for today.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8A96A8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableItems.length,
                itemBuilder: (context, index) {
                  final item = widget.availableItems[index];
                  final qty = _selectedItems[item] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A3A8F).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A2E6E),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: qty > 0 ? const Color(0xFFEAF2FF) : const Color(0xFFF0F5FB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove, color: Color(0xFF1A3A8F)),
                                  onPressed: qty > 0
                                      ? () => setState(() =>
                                          qty == 1 ? _selectedItems.remove(item) : _selectedItems[item] = qty - 1)
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2340),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Color(0xFF1A3A8F)),
                                  onPressed: () => setState(() => _selectedItems[item] = qty + 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _calculateTotalQty() > 0
                  ? () => Navigator.pop(context, _selectedItems)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Confirm Selection (${_calculateTotalQty()} items)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

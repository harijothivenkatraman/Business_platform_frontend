import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class B2BDataTableColumn {
  final String title;
  final int flex;
  final bool isNumeric;

  const B2BDataTableColumn({
    required this.title,
    this.flex = 1,
    this.isNumeric = false,
  });
}

class B2BDataTableRow {
  final List<Widget> cells;
  final String searchTerms;
  final VoidCallback? onTap;

  const B2BDataTableRow({
    required this.cells,
    required this.searchTerms,
    this.onTap,
  });
}

class B2BDataTable extends StatefulWidget {
  final String title;
  final List<B2BDataTableColumn> columns;
  final List<B2BDataTableRow> rows;
  final Widget? trailingHeader;
  final String searchHint;

  const B2BDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.trailingHeader,
    this.searchHint = 'Search records...',
  });

  @override
  State<B2BDataTable> createState() => _B2BDataTableState();
}

class _B2BDataTableState extends State<B2BDataTable> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRows = widget.rows.where((row) {
      if (_searchQuery.isEmpty) return true;
      return row.searchTerms.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title, style: AppTextStyles.h3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredRows.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 38,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (q) => setState(() => _searchQuery = q.trim()),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: widget.searchHint,
                          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                      ),
                    ),
                    if (widget.trailingHeader != null) ...[
                      const SizedBox(width: 12),
                      widget.trailingHeader!,
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Column Headers
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: widget.columns
                  .map((col) => Expanded(
                        flex: col.flex,
                        child: Text(
                          col.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: col.isNumeric ? TextAlign.right : TextAlign.left,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),

          // Rows
          if (filteredRows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No matching records found', style: AppTextStyles.caption),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredRows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final row = filteredRows[i];
                return InkWell(
                  onTap: row.onTap,
                  hoverColor: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: List.generate(row.cells.length, (idx) {
                        final flex = idx < widget.columns.length ? widget.columns[idx].flex : 1;
                        return Expanded(flex: flex, child: row.cells[idx]);
                      }),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

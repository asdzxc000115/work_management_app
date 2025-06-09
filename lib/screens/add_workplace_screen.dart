import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workplace.dart';
import '../providers/workplace_provider.dart';

class AddWorkplaceScreen extends StatefulWidget {
  final Workplace? workplace;

  AddWorkplaceScreen({this.workplace});

  @override
  _AddWorkplaceScreenState createState() => _AddWorkplaceScreenState();
}

class _AddWorkplaceScreenState extends State<AddWorkplaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedPayday = 25;
  Color _selectedColor = Colors.blue;
  bool _deductTax = false;
  bool _deductInsurance = false;

  final List<Color> _colorOptions = [
    Color(0xFF2196F3), // Blue
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFFC107), // Amber
    Color(0xFF009688), // Teal
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.workplace != null) {
      _nameController.text = widget.workplace!.name;
      _selectedPayday = widget.workplace!.payday;
      _selectedColor = widget.workplace!.color;
      _deductTax = widget.workplace!.deductTax;
      _deductInsurance = widget.workplace!.deductInsurance;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.workplace == null ? '근무지 추가' : '근무지 수정'),
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 헤더
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _nameController.text.isEmpty
                              ? '?'
                              : _nameController.text.substring(0, 1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.workplace == null
                          ? '새로운 근무지를 등록해주세요'
                          : '근무지 정보를 수정해주세요',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 근무지명
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '기본 정보',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: '근무지명',
                                hintText: '예: 카페, 편의점, 학원',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(Icons.business),
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                setState(() {}); // 프리뷰 업데이트
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '근무지명을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 월급일
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '월급일',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '급여가 지급되는 날짜를 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: _selectedPayday,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  borderRadius: BorderRadius.circular(12),
                                  items: List.generate(31, (index) => index + 1)
                                      .map((day) => DropdownMenuItem(
                                    value: day,
                                    child: Text(
                                      '매월 $day일',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPayday = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 색상 선택
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '테마 색상',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '캘린더에서 구분하기 쉬운 색상을 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _colorOptions.map((color) {
                                final isSelected = _selectedColor == color;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check, color: Colors.white, size: 24)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 세금 및 4대보험
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(
                                '공제 항목',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: Colors.orange[700],
                                ),
                              ),
                              title: Text(
                                '세금 공제',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '근로소득세 3.3%를 자동으로 계산합니다',
                                style: TextStyle(fontSize: 13),
                              ),
                              trailing: Switch(
                                value: _deductTax,
                                onChanged: (value) {
                                  setState(() {
                                    _deductTax = value;
                                  });
                                },
                                activeColor: Color(0xFF1976D2),
                              ),
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.health_and_safety,
                                  color: Colors.blue[700],
                                ),
                              ),
                              title: Text(
                                '4대보험 공제',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '국민연금, 건강보험, 고용보험, 산재보험을 계산합니다',
                                style: TextStyle(fontSize: 13),
                              ),
                              trailing: Switch(
                                value: _deductInsurance,
                                onChanged: (value) {
                                  setState(() {
                                    _deductInsurance = value;
                                  });
                                },
                                activeColor: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveWorkplace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.workplace == null ? '추가하기' : '수정하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWorkplace() {
    if (_formKey.currentState!.validate()) {
      final workplace = Workplace(
        id: widget.workplace?.id,
        name: _nameController.text.trim(),
        payday: _selectedPayday,
        color: _selectedColor,
        deductTax: _deductTax,
        deductInsurance: _deductInsurance,
      );

      final provider = Provider.of<WorkplaceProvider>(context, listen: false);

      if (widget.workplace == null) {
        provider.addWorkplace(workplace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('근무지가 추가되었습니다'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        provider.updateWorkplace(workplace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('근무지가 수정되었습니다'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }
}
//근무지 추가 화면
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
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
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
      appBar: AppBar(
        title: Text(widget.workplace == null ? '근무지 추가' : '근무지 수정'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 근무지명
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '근무지명',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '근무지명을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // 월급일
              Text(
                '월급일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedPayday,
                    items: List.generate(31, (index) => index + 1)
                        .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text('매월 $day일'),
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
              SizedBox(height: 20),

              // 색상 선택
              Text(
                '색상',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _selectedColor == color
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // 세금 및 4대보험
              Text(
                '공제 항목',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('세금 공제'),
                      subtitle: Text('근로소득세 3.3%를 자동으로 계산합니다'),
                      value: _deductTax,
                      onChanged: (value) {
                        setState(() {
                          _deductTax = value;
                        });
                      },
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      title: Text('4대보험 공제'),
                      subtitle: Text('국민연금, 건강보험, 고용보험, 산재보험을 자동으로 계산합니다'),
                      value: _deductInsurance,
                      onChanged: (value) {
                        setState(() {
                          _deductInsurance = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveWorkplace,
                  child: Text(
                    widget.workplace == null ? '추가하기' : '수정하기',
                    style: TextStyle(fontSize: 16),
                  ),
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
        name: _nameController.text,
        payday: _selectedPayday,
        color: _selectedColor,
        deductTax: _deductTax,
        deductInsurance: _deductInsurance,
      );

      final provider = Provider.of<WorkplaceProvider>(context, listen: false);

      if (widget.workplace == null) {
        provider.addWorkplace(workplace);
      } else {
        provider.updateWorkplace(workplace);
      }

      Navigator.of(context).pop();
    }
  }
}
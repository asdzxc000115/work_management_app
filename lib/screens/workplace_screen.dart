//근무지 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workplace_provider.dart';
import '../screens/add_workplace_screen.dart';

class WorkplaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workplaceProvider = Provider.of<WorkplaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('근무지 관리'),
      ),
      body: workplaceProvider.workplaces.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 근무지가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '근무지를 추가해주세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: workplaceProvider.workplaces.length,
        itemBuilder: (context, index) {
          final workplace = workplaceProvider.workplaces[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: workplace.color,
                child: Text(
                  workplace.name.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                workplace.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('월급일: ${workplace.payday}일'),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      if (workplace.deductTax)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '세금공제',
                            style: TextStyle(fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      if (workplace.deductInsurance)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '4대보험',
                            style: TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddWorkplaceScreen(
                          workplace: workplace,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, workplace.id!, workplace.name);
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkplaceScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('근무지 추가'),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int workplaceId, String workplaceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('근무지 삭제'),
        content: Text('\'$workplaceName\'을(를) 삭제하시겠습니까?\n삭제된 근무지의 모든 근무 기록도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<WorkplaceProvider>(context, listen: false)
                  .deleteWorkplace(workplaceId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
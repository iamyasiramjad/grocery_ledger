import 'package:flutter/material.dart';

class CreateGroceryListScreen extends StatefulWidget {
  const CreateGroceryListScreen({super.key});

  @override
  State<CreateGroceryListScreen> createState() =>
      _CreateGroceryListScreenState();
}

class _CreateGroceryListScreenState extends State<CreateGroceryListScreen> {
  // 1️⃣ STATE VARIABLES
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _importFromPrevious = true;

  // 2️⃣ LIFECYCLE
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 3️⃣ BUILD METHOD (ENTRY POINT)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Grocery List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDateField(context),
            const SizedBox(height: 24),
            _buildStartOptions(),
            const Spacer(),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  // 4️⃣ HELPER WIDGETS (PUT CODE HERE ⬇⬇⬇)

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'List name',
        hintText: 'January grocery list from Fine Store',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Shopping date',
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildStartOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start list by',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<bool>(
          value: true,
          groupValue: _importFromPrevious,
          onChanged: (value) {
            setState(() {
              _importFromPrevious = value!;
            });
          },
          title: const Text('Import items from previous month'),
        ),
        RadioListTile<bool>(
          value: false,
          groupValue: _importFromPrevious,
          onChanged: (value) {
            setState(() {
              _importFromPrevious = value!;
            });
          },
          title: const Text('Start from scratch'),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // next step
        },
        child: const Text('Create List'),
      ),
    );
  }
}

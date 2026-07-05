import 'package:flutter/material.dart';

import '../../services/organisation_service.dart';

class OrganisationPage extends StatefulWidget {
  const OrganisationPage({super.key});

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage> {

  List organisations = [];
  List filteredOrganisations = [];

  bool isLoading = true;

  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load organisations when page starts
    fetchOrganisations();
  }

  // Fetch organisations from API
 void fetchOrganisations() async {

  var data =
      await OrganisationService.getOrganisations();

  setState(() {
    organisations = data;
    filteredOrganisations = data;
    isLoading = false;
  });
}

void searchOrganisation(String keyword) {

  if (keyword.isEmpty) {

    setState(() {
      filteredOrganisations = organisations;
    });

    return;
  }

  final results = organisations.where((organisation) {

    final name =
        organisation['name']
            .toString()
            .toLowerCase();

    final category =
        organisation['category']
            .toString()
            .toLowerCase();

    return name.contains(
             keyword.toLowerCase(),
           ) ||
           category.contains(
             keyword.toLowerCase(),
           );

  }).toList();

  setState(() {
    filteredOrganisations = results;
  });
}
@override
void dispose() {
  searchController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Trusted Organisations",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        backgroundColor: Colors.blue,
        centerTitle: true,
      ),

      body: isLoading

          // Loading State
          ? const Center(
              child: CircularProgressIndicator(),
            )

          // Organisation List
          : Column(
    children: [

      Padding(
        padding: const EdgeInsets.all(16),

        child: TextField(
          controller: searchController,

          onChanged: searchOrganisation,

          decoration: InputDecoration(
            hintText: "Search Organisation",
            prefixIcon:
                const Icon(Icons.search),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      Expanded(
        child: ListView.builder(
          padding:
              const EdgeInsets.all(16),

              itemCount: 
                  filteredOrganisations.length,

              itemBuilder: (context, index) {

               var organisation =
                    filteredOrganisations[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),

                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Verified Icon
                      Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Organisation Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Organisation Name
                            Text(
                              organisation['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Website
                            Text(
                              organisation['website'],
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),

                              child: Text(
                                organisation['category'],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Status
                            Row(
                              children: const [

                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),

                                SizedBox(width: 6),

                                Text(
                                  "Verified Organisation",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
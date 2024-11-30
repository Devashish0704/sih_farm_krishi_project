import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CompactCropInsightsCarousel extends StatefulWidget {
  @override
  _CompactCropInsightsCarouselState createState() =>
      _CompactCropInsightsCarouselState();
}

class _CompactCropInsightsCarouselState
    extends State<CompactCropInsightsCarousel> {
  final List<Map<String, dynamic>> _cropInsights = [
    {
      'cropName': 'Wheat',
      'healthStatus': 'Good',
      'stage': 'Flowering',
      'recommendedAction':
          'Apply nitrogen fertilizer to enhance crop growth and yield',
      'healthPercentage': 0.8,
      'icon': Icons.grass
    },
    {
      'cropName': 'Tomatoes',
      'healthStatus': 'Moderate',
      'stage': 'Fruiting',
      'recommendedAction':
          'Monitor for pest infestation and apply organic pest control',
      'healthPercentage': 0.6,
      'icon': Icons.agriculture
    },
    {
      'cropName': 'Rice',
      'healthStatus': 'Needs Attention',
      'stage': 'Growth',
      'recommendedAction': 'Improve water management and check drainage system',
      'healthPercentage': 0.4,
      'icon': Icons.rice_bowl
    }
  ];

  void _showCropDetailsBottomSheet(
      BuildContext context, Map<String, dynamic> cropData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cropData['cropName']} Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getHealthStatusColor(
                                cropData['healthPercentage']),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cropData['healthStatus'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Crop Details
                    _buildDetailRow('Current Stage', cropData['stage']),
                    _buildDetailRow('Health',
                        '${(cropData['healthPercentage'] * 100).toStringAsFixed(0)}%'),

                    SizedBox(height: 20),
                    Text(
                      'Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cropData['recommendedAction'],
                        style: TextStyle(
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getHealthStatusColor(double percentage) {
    if (percentage > 0.7) return Colors.green;
    if (percentage > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> cropData) {
    return GestureDetector(
      onTap: () => _showCropDetailsBottomSheet(context, cropData),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(115, 174, 253, 244),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Crop Icon
              Container(
                decoration: BoxDecoration(
                  color: _getHealthStatusColor(cropData['healthPercentage'])
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Icon(
                  cropData['icon'],
                  color: _getHealthStatusColor(cropData['healthPercentage']),
                  size: 30,
                ),
              ),
              SizedBox(width: 12),

              // Crop Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${cropData['cropName']} | ${cropData['stage']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cropData['recommendedAction'],
                      maxLines: 2,
                      //overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Health Percentage
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHealthStatusColor(cropData['healthPercentage'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(cropData['healthPercentage'] * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getHealthStatusColor(cropData['healthPercentage']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
          ),
          items: _cropInsights.map((crop) => _buildCropCard(crop)).toList(),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:expandable/expandable.dart';

// class CompactCropInsightsCarousel extends StatefulWidget {
//   @override
//   _CompactCropInsightsCarouselState createState() =>
//       _CompactCropInsightsCarouselState();
// }

// class _CompactCropInsightsCarouselState
//     extends State<CompactCropInsightsCarousel> {
//   final List<Map<String, dynamic>> _cropInsights = [
//     {
//       'cropName': 'Wheat',
//       'healthStatus': 'Good',
//       'stage': 'Flowering',
//       'recommendedAction': 'Apply nitrogen fertilizer',
//       'healthPercentage': 0.8,
//       'icon': Icons.grass
//     },
//     {
//       'cropName': 'Tomatoes',
//       'healthStatus': 'Moderate',
//       'stage': 'Fruiting',
//       'recommendedAction': 'Monitor for pest infestation',
//       'healthPercentage': 0.6,
//       'icon': Icons.agriculture
//     },
//     {
//       'cropName': 'Rice',
//       'healthStatus': 'Needs Attention',
//       'stage': 'Growth',
//       'recommendedAction': 'Improve water management',
//       'healthPercentage': 0.4,
//       'icon': Icons.rice_bowl
//     }
//   ];

//   Color _getHealthStatusColor(double percentage) {
//     if (percentage > 0.7) return Colors.green;
//     if (percentage > 0.4) return Colors.orange;
//     return Colors.red;
//   }

//   Widget _buildCompactCropCard(Map<String, dynamic> cropData) {
//     return ExpandableNotifier(
//       child: ScrollOnExpand(
//         child: ExpandablePanel(
//           collapsed: _buildCollapsedPanel(cropData),
//           expanded: _buildExpandedPanel(cropData),
//           theme: ExpandableThemeData(
//             headerAlignment: ExpandablePanelHeaderAlignment.center,
//             tapBodyToExpand: true,
//             tapBodyToCollapse: true,
//             hasIcon: true,
//             iconColor: Colors.green,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCollapsedPanel(Map<String, dynamic> cropData) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           children: [
//             // Crop Icon
//             Container(
//               decoration: BoxDecoration(
//                 color: _getHealthStatusColor(cropData['healthPercentage'])
//                     .withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: EdgeInsets.all(10),
//               child: Icon(
//                 cropData['icon'],
//                 color: _getHealthStatusColor(cropData['healthPercentage']),
//                 size: 30,
//               ),
//             ),
//             SizedBox(width: 12),

//             // Crop Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     cropData['cropName'],
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green[800],
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '${cropData['stage']} | ${cropData['healthStatus']}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Health Percentage
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _getHealthStatusColor(cropData['healthPercentage'])
//                     .withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 '${(cropData['healthPercentage'] * 100).toStringAsFixed(0)}%',
//                 style: TextStyle(
//                   color: _getHealthStatusColor(cropData['healthPercentage']),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandedPanel(Map<String, dynamic> cropData) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Expanded Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${cropData['cropName']} Insights',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green[800],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getHealthStatusColor(cropData['healthPercentage']),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     cropData['healthStatus'],
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),

//             // Detailed Insights
//             _buildInsightRow('Current Stage', cropData['stage']),
//             _buildInsightRow(
//                 'Recommended Action', cropData['recommendedAction']),

//             SizedBox(height: 12),

//             // Action Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Add action for crop details
//                   },
//                   icon: Icon(Icons.info_outline, size: 18),
//                   label: Text('More Details'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green[50],
//                     foregroundColor: Colors.green[800],
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Add action for recommendations
//                   },
//                   icon: Icon(Icons.agriculture, size: 18),
//                   label: Text('Recommendations'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[50],
//                     foregroundColor: Colors.blue[800],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInsightRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey[800],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text(
//             'Crop Insights',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 120,
//             aspectRatio: 16 / 9,
//             viewportFraction: 0.9,
//             enableInfiniteScroll: false,
//             enlargeCenterPage: true,
//           ),
//           items:
//               _cropInsights.map((crop) => _buildCompactCropCard(crop)).toList(),
//         ),
//       ],
//     );
//   }
// }

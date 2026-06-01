import 'package:trafficlly/utills/export.dart';

class NPFBottomSheet extends StatelessWidget {
  String? title;
  List<String>? options;

  NPFBottomSheet({super.key, required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: AppColors.appPrimary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText(
                text: title ?? 'Choose Options',
                textAlign: TextAlign.center,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: options!
                  .map(
                    (item) => GestureDetector(
                      onTap: () => Get.back(result: item),
                      child: BottomSheetItem(title: item),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetItem extends StatelessWidget {
  String title;

  BottomSheetItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            text: title,
            textAlign: TextAlign.center,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
          const Divider(),
        ],
      ),
    );
  }
}

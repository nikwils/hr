enum ImgsControllerService {
  defaultImg,
}

extension ImgsControllerServiceExtension on ImgsControllerService {
  String url() {
    const format = '.png';

    switch (this) {
      case ImgsControllerService.defaultImg:
        return 'assets/imgs/default_img_card$format';
    }
  }
}

import Foundation
import TKUIKit
import UIKit
import KeeperCore
import TKCore

protocol TokenDetailsModuleOutput: AnyObject {
  var didTapSend: ((KeeperCore.Token) -> Void)? { get set }
  var didTapReceive: ((KeeperCore.Token) -> Void)? { get set }
    
  var didTapBuyOrSell: ((KeeperCore.Token) -> Void)? { get set }
  var didTapStaking: ((KeeperCore.Token) -> Void)? { get set }
  var didTapSwap: ((KeeperCore.Token) -> Void)? { get set }
}

protocol TokenDetailsViewModel: AnyObject {
  var didUpdateTitleView: ((TokenDetailsTitleView.Model) -> Void)? { get set }
  var didUpdateInformationView: ((TokenDetailsInformationView.Model) -> Void)? { get set }
  var didUpdateButtonsView: ((TokenDetailsHeaderButtonsView.Model) -> Void)? { get set }
  var didUpdateChartViewController: ((UIViewController) -> Void)? { get set }
  
  func viewDidLoad()
}

final class TokenDetailsViewModelImplementation: TokenDetailsViewModel, TokenDetailsModuleOutput {
  
  // MARK: - TokenDetailsModuleOutput
  
  var didTapSend: ((KeeperCore.Token) -> Void)?
  var didTapReceive: ((KeeperCore.Token) -> Void)?
    
  var didTapBuyOrSell: ((KeeperCore.Token) -> Void)?
  var didTapStaking: ((KeeperCore.Token) -> Void)?
  var didTapSwap: ((KeeperCore.Token) -> Void)?
  
  // MARK: - TokenDetailsViewModel
  
  var didUpdateTitleView: ((TokenDetailsTitleView.Model) -> Void)?
  var didUpdateInformationView: ((TokenDetailsInformationView.Model) -> Void)?
  var didUpdateButtonsView: ((TokenDetailsHeaderButtonsView.Model) -> Void)?
  var didUpdateChartViewController: ((UIViewController) -> Void)?
  
  func viewDidLoad() {
    Task {
      tokenDetailsController.didUpdate = { [weak self] model in
        self?.didUpdateTokenModel(model: model)
      }
      await tokenDetailsController.start()
    }
    setupChart()
  }
  
  // MARK: - Image Loading
  
  private let imageLoader = ImageLoader()

  // MARK: - Dependencies
  
  private let tokenDetailsController: TokenDetailsController
  private let chartViewControllerProvider: (() -> UIViewController?)?
  
  // MARK: - Init
  
  init(tokenDetailsController: TokenDetailsController,
       chartViewControllerProvider: (() -> UIViewController?)?) {
    self.tokenDetailsController = tokenDetailsController
    self.chartViewControllerProvider = chartViewControllerProvider
  }
}

private extension TokenDetailsViewModelImplementation {
  func didUpdateTokenModel(model: TokenDetailsController.TokenModel) {
    Task { @MainActor in
      setupTitleView(model: model)
      setupInformationView(model: model)
      setupButtonsView(model: model)
    }
  }
  
  func setupTitleView(model: TokenDetailsController.TokenModel) {
    didUpdateTitleView?(
      TokenDetailsTitleView.Model(
        title: model.tokenTitle,
        warning: model.tokenSubtitle
      )
    )
  }
  
  func setupButtonsView(model: TokenDetailsController.TokenModel) {
    let mapper = IconButtonModelMapper()
    let buttons = model.buttons.map { buttonModel in
      TokenDetailsHeaderButtonsView.Model.Button(
        configuration: mapper.mapButton(model: buttonModel),
        action: { [weak self] in
          switch buttonModel {
          case .send(let token):
            self?.didTapSend?(token)
          case .receive(let token):
            self?.didTapReceive?(token)
          case .buySell(let token):
              self?.didTapBuyOrSell?(token)
          case .stake(let token):
              self?.didTapStaking?(token)
          case .swap(let token):
              self?.didTapSwap?(token)
          default:
            break
          }
        }
      )
    }
    let model = TokenDetailsHeaderButtonsView.Model(buttons: buttons)
    didUpdateButtonsView?(model)
  }
  
  func setupInformationView(model: TokenDetailsController.TokenModel) {
    let image: TokenDetailsInformationView.Model.Image
    switch model.image {
    case .ton:
      image = .image(.TKCore.Icons.Size44.tonLogo)
    case .url(let url):
      image = .asyncImage(
        TKCore.ImageDownloadTask(
          closure: {
            [imageLoader] imageView,
            size,
            cornerRadius in
            return imageLoader.loadImage(url: url, imageView: imageView, size: size, cornerRadius: cornerRadius)
          }
        )
      )
    }
    
    didUpdateInformationView?(
      TokenDetailsInformationView.Model(
        image: image,
        tokenAmount: model.tokenAmount,
        convertedAmount: model.convertedAmount
      )
    )
  }
  
  func setupChart() {
    guard let chartViewController = chartViewControllerProvider?() else { return }
    didUpdateChartViewController?(chartViewController)
  }
}

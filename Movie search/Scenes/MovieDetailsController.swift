import UIKit
import Kingfisher

class MovieDetailsController: UIViewController {

    @IBOutlet var plot: UITextView?
    @IBOutlet var staring: UILabel?
    @IBOutlet var director: UILabel?
    @IBOutlet var poster: UIImageView?
    @IBOutlet var TitleText: UILabel?
    @IBOutlet var rating: UILabel?

    var movieResult: MovieInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backBarBtnItem = UIBarButtonItem()
        backBarBtnItem.title = "Results"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backBarBtnItem

        TitleText?.text = movieResult?.Title
        director?.text = movieResult?.Director
        staring?.text = movieResult?.Actors
        plot?.text = movieResult?.Plot

        if movieResult?.Poster?.absoluteString == "N/A"{
            movieResult?.Poster? = URL(string: NoImageURL)!
        }

        rating?.text = ""
        for data in movieResult?.Ratings ?? []{
            rating?.text! +=  data.Source + ":\n  " + data.Value + "\n"
        }

        poster?.kf.setImage(with: movieResult?.Poster)
    }
}

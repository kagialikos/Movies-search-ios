import UIKit
import Kingfisher

let apikey = "baa9d85f"
let NoImageURL = "https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-15.png"


class searchMovieController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var SearchTable: UITableView!

    var page = 0
    var totalresult = 0
    var isloading = false
    var Movies = [Movie]()

    var detailControllerIdentifier = "Details"
    var loadingCellIdentifier = "loadingCell"
    var movieCellIdentifier = "SearchMovieCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.showsScopeBar = true
        searchBar.delegate = self

        searchTableRegister()
    }

    private func searchTableRegister(){
        SearchTable.delegate = self
        SearchTable.dataSource = self
        SearchTable.register(UINib(nibName:movieCellIdentifier, bundle: nil), forCellReuseIdentifier: movieCellIdentifier)
        SearchTable.register(UINib(nibName:loadingCellIdentifier, bundle: nil), forCellReuseIdentifier: loadingCellIdentifier)
        SearchTable.tableFooterView = UIView()
    }

    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        page = 1
        Movies.removeAll()
        SearchTable.reloadData()
        searchBar.resignFirstResponder()
        movieSearch(searchMovieName: searchBar.text ?? "")
    }

    private func noResultMessage(){
        let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.SearchTable.bounds.size.width, height: self.SearchTable.bounds.size.height))
        noDataLabel.text          = "No result found!"
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        SearchTable.backgroundView  = noDataLabel
        SearchTable.separatorStyle  = .none
    }

    private func navigateToDetail(movieResult: MovieInfo){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultView = storyBoard.instantiateViewController(withIdentifier: detailControllerIdentifier) as! MovieDetailsController
        resultView.movieResult = movieResult
        navigationController?.pushViewController(resultView, animated: true)
    }

    //search for movies
    func movieSearch(searchMovieName: String){
        guard let url = URL(string: "https://www.omdbapi.com/?s=" + searchMovieName + "&page=" + String(page) + "&type=movie&apikey=" + apikey) else{ fatalError("invalid url") }

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let movieResult = try JSONDecoder().decode(MovieFeed.self, from: data)
                DispatchQueue.main.async {
                    self.isloading = false
                    if movieResult.Response == "False"{
                        self.noResultMessage()
                    }
                    else{
                        self.SearchTable.backgroundView = .none
                        self.SearchTable.separatorStyle = .singleLine
                        
                        for movie in movieResult.Search ?? [] {
                            self.Movies.append(movie)
                        }
                        self.totalresult = Int(movieResult.totalResults ?? "0") ?? 0
                        self.SearchTable.reloadData()
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    //load movie detail and navigate to "detail screen"
    func getMovieInfo(imdbID: String){
        guard let url = URL(string: "https://www.omdbapi.com/?i=" + imdbID + "&page=1&type=movie&apikey=" + apikey) else {fatalError("invalid url")}
        let request = URLRequest(url: url)
        self.showloading()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            do {
                let movieResult = try JSONDecoder().decode(MovieInfo.self, from: data)
                DispatchQueue.main.async {
                    self.dismiss(animated: false){
                        self.navigateToDetail(movieResult: movieResult)
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    // MARK: - tableView settings
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isloading && Movies.count == indexPath.row{
            return 50 //loading cell
        }
        else{
            return 90
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isloading {
            return Movies.count + 1 //loading cell
        }
        else{
            return Movies.count
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getMovieInfo(imdbID: Movies[indexPath.row].imdbID)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isloading && Movies.count == indexPath.row{
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellIdentifier, for: indexPath) as? loadingCell
            cell?.isUserInteractionEnabled = false //loading cell disable interaction
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: movieCellIdentifier, for: indexPath) as? SearchMovieCell
            cell?.Title.text = Movies[indexPath.row].Title
            cell?.Date.text = Movies[indexPath.row].Year

            if Movies[indexPath.row].Poster.absoluteString == "N/A"{
                Movies[indexPath.row].Poster = URL(string: NoImageURL)!
            }
            cell?.Poster.kf.setImage(with: Movies[indexPath.row].Poster)

            return cell!
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // if the last cell of tableview is visible and there is more pages to load, load next page
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath && indexPath.row == Movies.count-1 && !isloading && page*10 < totalresult {
                page += 1
                isloading = true
                DispatchQueue.main.async {
                    self.SearchTable.reloadData()
                }
                movieSearch(searchMovieName: searchBar.text ?? "")
            }
        }
    }

    // MARK: - loading Alert
    func showloading(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - hide/show navigationbar
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}

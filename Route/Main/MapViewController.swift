//
//  MapViewController.swift
//  
//
//  Created by Евгений Иванов on 05/08/2019.
//

import UIKit
import GoogleMaps
import RealmSwift
import SwiftKeychainWrapper

class MapViewController: UIViewController {
    var startCoordinate = CLLocationCoordinate2D(latitude: 56.8423651, longitude: 60.5973017)
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    let locationManager = LocationManager.instance
    var coordinates = [Coordinate]()
    var locationEnabled = false
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lastRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationLocationManager()
        configureMap(coordinate: self.startCoordinate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if locationEnabled == true {
                stopUpdateLocationActions()
            }
        }
    }
    
    func configurationLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location, let self = self else { return }
                let coordinate = Coordinate(coordinates: location.coordinate)
                self.coordinates.append(coordinate)
                /// Добавляем её в путь маршрута
                self.routePath?.add(location.coordinate)
                /// Обновляем путь у линии маршрута путём повторного присвоения
                self.route?.path = self.routePath
                /// Чтобы наблюдать за движением, установим камеру на только что добавленную точку
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self.updateMarker(coordinate: location.coordinate)
                self.mapView.animate(to: position)
                
        }
    }
    
    /// Конфигурация карты
    func configureMap(coordinate: CLLocationCoordinate2D) {
        /// Создаём камеру с использованием координат и уровнем увеличения
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
    }
    /// Добвление маркера
    func updateMarker(coordinate: CLLocationCoordinate2D) {
        marker?.map = nil
        marker = nil
        let marker = GMSMarker.init(position: coordinate)
        marker.map = mapView
        marker.title = "Я тут"
        marker.icon = loadSelfieFromDisk()
        marker.setIconSize(scaledToSize: .init(width: 40, height: 40))
        self.marker = marker
    }
    
    func createNewRoute(strokeWidth: CGFloat, strokeColor: UIColor) -> GMSPolyline {
        let newRoute = GMSPolyline()
        newRoute.strokeWidth = strokeWidth
        newRoute.strokeColor = strokeColor
        return newRoute
    }
    
    func stopUpdateLocationActions() {
        locationManager.stopUpdatingLocation()
        guard let login: String = KeychainWrapper.standard.string(forKey: "currentUser") else { return }
        DatabaseService.updateCoordinates(login: login, coordinates: coordinates)
        coordinates.removeAll()
        locationEnabled = false
    }
    
    func showStopAlert() {
        
        let alert = UIAlertController(title: "Предупреждение", message: "При показе предыдущего маршрута остановится слежение. Показать маршрут?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        let action = UIAlertAction(title: "Да", style: .default) { (action) in
            self.stopUpdateLocationActions()
            self.showLastCoordinates()
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createNewRoute() {
        route?.map = nil
        // Заменяем старую линию новой
        route = createNewRoute(strokeWidth: 4, strokeColor: .magenta)
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView
    }
    
    func showLastCoordinates() {
        
        guard
            let login: String = KeychainWrapper.standard.string(forKey: "currentUser"),
            let user = DatabaseService.getObject(type: User.self, login: login)
            else { return }
        createNewRoute()
        guard let path = routePath else { return }
        for eachCoordinate in user.coordinates {
            path.addLatitude(eachCoordinate.latitude, longitude: eachCoordinate.longitude)
        }
        route?.path = path
        let bounds = GMSCoordinateBounds(path: path)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 30.0)
        mapView.moveCamera(update)
    }
    
    @IBAction func startUpdateLocation(_ sender: Any) {
        if locationEnabled == false {
            coordinates.removeAll()
            route?.map = nil
            createNewRoute()
            // Запускаем отслеживание или продолжаем, если оно уже запущено
            locationManager.startUpdatingLocation()
            locationEnabled = true
        }
    }
    @IBAction func stopUpdateLocation(_ sender: Any) {
        if locationEnabled == true {
            stopUpdateLocationActions()
        }
        
    }
    @IBAction func showLastRoute(_ sender: Any) {
        if locationEnabled == true {
            showStopAlert()
        } else {
            showLastCoordinates()
        }
    }
}

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}

extension MapViewController: UINavigationControllerDelegate {
    
}

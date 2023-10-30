//
//  ViewController.swift
//  QueaColleccionDeJuegos
//
//  Created by Ruben Freddy Quea Jacho on 27/10/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JuegoDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    var juegos : [Juego] = []
    var categorias: [Categoria] = []
    
    struct CategoriaInfo {
        var categoria: Categoria
        var juegos: [Juego]
    }
    
    var categoriasInfo: [CategoriaInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        //categorias = agregarCategorias()
        obtenerCategorias()
        navigationController?.delegate = self
        categoriasInfo.removeAll()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try juegos = context.fetch(Juego.fetchRequest())
            for categoria in categorias {
                let juegosCategoria = juegos.filter { $0.categoria == categoria.nombre }
                categoriasInfo.append(CategoriaInfo(categoria: categoria, juegos: juegosCategoria))
            }
            tableView.reloadData()
        } catch  {
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    
    func obtenerCategorias() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try categorias = context.fetch(Categoria.fetchRequest())
        } catch {
            print("Error al obtener categorías: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriasInfo[section].juegos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let juego = categoriasInfo[indexPath.section].juegos[indexPath.row]
        cell.textLabel?.text = juego.titulo
        cell.imageView?.image = UIImage(data: juego.imagen!)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cell.addGestureRecognizer(gestureRecognizer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Habilita la edición para todas las filas
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let juego = categoriasInfo[indexPath.section].juegos[indexPath.row]
        performSegue(withIdentifier: "juegoSegue", sender: juego)
    }
    
    func juegoAgregado() {
        obtenerCategorias()
        categoriasInfo.removeAll()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try juegos = context.fetch(Juego.fetchRequest())
            for categoria in categorias {
                let juegosCategoria = juegos.filter { $0.categoria == categoria.nombre }
                categoriasInfo.append(CategoriaInfo(categoria: categoria, juegos: juegosCategoria))
            }
            tableView.reloadData()
        } catch  {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let juegosVC = segue.destination as? JuegosViewController {
            juegosVC.delegate = self
        }
        
        if let siguienteVC = segue.destination as? JuegosViewController {
            siguienteVC.juego = sender as? Juego
            siguienteVC.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let juego = categoriasInfo[indexPath.section].juegos[indexPath.row]
            context.delete(juego)
            categoriasInfo[indexPath.section].juegos.remove(at: indexPath.row)
            do {
                try context.save()
            } catch {
                print("Error al guardar: \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedJuego = categoriasInfo[sourceIndexPath.section].juegos.remove(at: sourceIndexPath.row)
        categoriasInfo[destinationIndexPath.section].juegos.insert(movedJuego, at: destinationIndexPath.row)
        movedJuego.categoria = categoriasInfo[destinationIndexPath.section].categoria.nombre
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            print("Error al guardar: \(error)")
        }
        
        tableView.reloadData()
    }


    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoriasInfo.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoriasInfo[section].categoria.nombre
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? UITableViewCell else {
            return
        }

        let translation = gestureRecognizer.translation(in: tableView)
        switch gestureRecognizer.state {
        case .changed:
            if let indexPath = tableView.indexPath(for: cell), let destinationIndexPath = tableView.indexPathForRow(at: gestureRecognizer.location(in: tableView)) {
                if indexPath.section == destinationIndexPath.section {
                    tableView.beginUpdates()
                    tableView.moveRow(at: indexPath, to: destinationIndexPath)
                    juegos.swapAt(indexPath.row, destinationIndexPath.row)
                    gestureRecognizer.setTranslation(.zero, in: tableView)
                    tableView.endUpdates()
                }
            }
        default:
            break
        }
    }

    
    func agregarCategorias() -> [Categoria] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let nombresCategorias = ["Acción", "Aventura", "Estrategia", "Deportes", "Puzzle", "RPG", "Simulación", "Casual", "Plataformas", "Multijugador"]
        var categoriasAgregadas: [Categoria] = []
        
        for nombre in nombresCategorias {
            let categoria = Categoria(context: context)
            categoria.nombre = nombre
            categoriasAgregadas.append(categoria)
        }
        
        do {
            try context.save()
            print("Categorías agregadas correctamente")
        } catch {
            print("Error al agregar categorías: \(error)")
        }
        
        return categoriasAgregadas
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorias.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorias[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Aquí puedes guardar la categoría seleccionada
    }

}


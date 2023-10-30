//
//  JuegosViewController.swift
//  QueaColleccionDeJuegos
//
//  Created by Ruben Freddy Quea Jacho on 27/10/23.
//

import UIKit

protocol JuegoDelegate: AnyObject {
    func juegoAgregado()
}


class JuegosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var agregarActualizarBoton: UIButton!
    @IBOutlet weak var eliminarBoton: UIButton!
    @IBOutlet weak var categoriaPickerView: UIPickerView!
    weak var delegate: JuegoDelegate?
    
    var imagePicker = UIImagePickerController()
    
    var juego:Juego? = nil
    var categoriaSeleccionada: Categoria? = nil
    var categorias: [Categoria] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtenerCategorias()
        categoriaPickerView.dataSource = self
        categoriaPickerView.delegate  = self
        imagePicker.delegate = self
        
        if juego != nil {
            imageView.image = UIImage(data: (juego!.imagen!) as Data)
            tituloTextField.text = juego!.titulo
            if let categoriaNombre = juego!.categoria {
                if let index = categorias.firstIndex(where: { $0.nombre == categoriaNombre }) {
                    categoriaPickerView.selectRow(index, inComponent: 0, animated: true)
                    print(index)
                    //categoriaSeleccionada = index
                }
            }
            agregarActualizarBoton.setTitle("Actualizar", for: .normal)
        }else{
            eliminarBoton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        obtenerCategorias()
    }
    
   

    func obtenerCategorias() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try categorias = context.fetch(Categoria.fetchRequest())
            print(categorias)
        } catch {
            print("Error al obtener categorías: \(error)")
        }
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorias.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorias[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoriaSeleccionada = categorias[row]
        print("Categoría seleccionada: \(categoriaSeleccionada?.nombre ?? "N/A")")
    }


    
    @IBAction func fotosTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func agregarTapped(_ sender: Any) {
        if juego != nil {
                guard let categoriaSeleccionada = categoriaSeleccionada else {
                    // Mostrar una alerta o manejar el caso en el que la categoría no esté seleccionada
                    return
                }
                juego!.titulo = tituloTextField.text
                juego!.imagen = imageView.image?.jpegData(compressionQuality: 0.50)
                juego!.categoria = categoriaSeleccionada.nombre
            } else {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let juego = Juego(context: context)
                juego.titulo = tituloTextField.text
                juego.imagen = imageView.image?.jpegData(compressionQuality: 0.50)
                juego.categoria = categoriaSeleccionada?.nombre
                
            }
            delegate?.juegoAgregado()
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController?.popViewController(animated: true)
    }
    
    @IBAction func eliminarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(juego!)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagenSeleccionada = info[.originalImage] as? UIImage
        imageView.image = imagenSeleccionada
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

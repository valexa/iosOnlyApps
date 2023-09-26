//
//  GraphsViewController.swift
//  VAInfo
//
//  Created by Vlad on 26/12/2017.
//

import UIKit
import Charts

@objc class GraphsViewController: UIViewController {

    @IBOutlet var cpuChart: LineChartView!
    @IBOutlet var memChart: LineChartView!
    @IBOutlet var battChart: LineChartView!

    var cpuHistory = [ChartDataEntry]()
    var memHistory = [ChartDataEntry]()
    var battHistory = [ChartDataEntry]()

    var refreshTimer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()

        refreshTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)

        refresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(cpuChart, title: "CPU")
        configure(memChart, title: "Memory")
        configure(battChart, title: "Battery")

        battChart.leftAxis.axisMaximum = 100
        memChart.leftAxis.axisMaximum = 100

    }

    func configure(_ chart: LineChartView, title: String) {
        chart.delegate = self
        chart.backgroundColor = .white
        chart.setScaleEnabled(true)
        chart.chartDescription?.text = title
        chart.legend.form = .line
        chart.legend.enabled = false
        chart.xAxis.enabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.axisMinimum = 0
    }

    @objc func refresh() {

        //print(Sysctl.model)

        let sysinfo = SysInfo.Query.Hardware()

        cpuHistory.append(ChartDataEntry(x: Double(cpuHistory.count), y: Double(sysinfo.load)))
        memHistory.append(ChartDataEntry(x: Double(memHistory.count), y: Double(sysinfo.memoryPercent)))
        battHistory.append(ChartDataEntry(x: Double(battHistory.count), y: Double(UIDevice.current.batteryLevel * 100)))

        if cpuHistory.count > 1000 {
            cpuHistory.removeFirst()
            cpuChart.animate(xAxisDuration: 1)
        }
        if memHistory.count > 1000 {
            memHistory.removeFirst()
            memChart.animate(xAxisDuration: 1)
        }
        if battHistory.count > 1000 {
            battHistory.removeFirst()
            battChart.animate(xAxisDuration: 1)
        }

        guard cpuChart != nil, memChart != nil, battChart != nil else {return}

        cpuChart.data = lineData(cpuHistory, label: "CPU", color: UIColor.darkGray)
        memChart.data = lineData(memHistory, label: "Memory", color: UIColor.darkGray)
        battChart.data = lineData(battHistory, label: "Battery", color: UIColor.darkGray)

    }

    func lineData(_ values: [ChartDataEntry]?, label: String, color: UIColor) -> LineChartData {

        let dataSet = LineChartDataSet(values: values, label: label)
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false

        dataSet.setColor(color)
        dataSet.setCircleColor(color)
        dataSet.lineWidth = 0
        dataSet.circleRadius = 0
        dataSet.drawCircleHoleEnabled = false
        dataSet.valueFont = .systemFont(ofSize: 9)
        dataSet.formLineDashLengths = [5, 2.5]

        let gradientColors = [UIColor.white.cgColor, color.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        dataSet.fillAlpha = 1
        dataSet.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        dataSet.drawFilledEnabled = true

        return LineChartData(dataSet: dataSet)
    }

}

extension GraphsViewController: ChartViewDelegate {

}

//
//  YAxisLayout.swift
//  BarChart
//
//  Copyright (c) 2020 Roman Baitaliuk
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

public class YAxis: AxisBase {
    
    // MARK: - Public Properties
    
    /// Minimum spacing between the ticks in pixels
    @Published public var minTicksSpacing: CGFloat = 40.0
    
    @Published public var formatter: ((Double, Int) -> String) = {
        return { return String(format: "%.\($1)f", $0) }
    }()
    
    // MARK: - Internal Properties
    
    @Published var data: [Double] = [] {
        didSet {
            self.updateScaler()
        }
    }
    
    @Published var frameHeight: CGFloat? {
        didSet {
            self.updateScaler()
        }
    }
    
    var scaler: YAxisScaler?
    
    // MARK: - Private Properties
    
    private var maxTicks: Int? {
        guard let frameHeight = self.frameHeight,
            self.minTicksSpacing != 0 else { return nil }
        return Int(frameHeight / self.minTicksSpacing)
    }
    
    // MARK: - Internal Methods
    
    override func formattedLabels() -> [String] {
        guard let tickSpacing = self.scaler?.tickSpacing else { return [] }
        return self.scaler?.scaledValues().map { self.formatter($0, tickSpacing.decimalsCount()) } ?? []
    }
    
    func labelValue(at index: Int) -> Double? {
        return self.scaler?.scaledValues()[index]
    }
    
    func pixelsRatio() -> CGFloat? {
        guard let frameHeight = self.frameHeight,
            let verticalDistance = self.verticalDistance(),
            verticalDistance != 0 else { return nil }
        return frameHeight / CGFloat(verticalDistance)
    }
    
    func centre() -> CGFloat? {
        guard let chartMin = self.scaler?.scaledMin,
            let pixelsRatio = self.pixelsRatio() else { return nil }
        return CGFloat(chartMin) * pixelsRatio
    }
       
    func normalizedValues() -> [Double] {
        guard let verticalDistance = self.verticalDistance(),
            verticalDistance != 0 else { return [] }
        return self.data.map { $0 / verticalDistance }
    }
    
    // MARK: - Private Methods
    
    private func updateScaler() {
        guard let minValue = self.data.min(),
            let maxValue = self.data.max(),
            let maxTicks = self.maxTicks else {
                self.scaler = nil
                return
        }
        let adjustedMin = minValue > 0 ? 0 : minValue
        let adjustedMax = maxValue < 0 ? 0 : maxValue
        self.scaler = YAxisScaler(min: adjustedMin, max: adjustedMax, maxTicks: maxTicks)
    }
    
    private func verticalDistance() -> Double? {
        guard let chartMax = self.scaler?.scaledMax,
            let chartMin = self.scaler?.scaledMin else { return nil }
        return abs(chartMax) + abs(chartMin)
    }
}

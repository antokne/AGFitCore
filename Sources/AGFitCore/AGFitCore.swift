public struct AGFitCore {

    public init() {
    }
	

	public static func calculateSampleRateforFitFile(with size: Int) -> Int {
		var sampleRate = 0 // default include all samples
		if size > 1000000 {
			sampleRate = 30
		}
		else if size > 500000 {
			sampleRate = 10
		}
		else if size > 100000 {
			sampleRate = 5
		}
		return sampleRate
	}
}

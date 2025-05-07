import Foundation

class ScheduleViewModel {
    // 의존성
    private let jobService = JobService.shared
    
    // 상태
    private(set) var jobs: [Job] = []
    private(set) var isLoading = false
    private(set) var selectedDate: Date?
    private(set) var currentMonth: Date?
    private var monthJobs: [Date: [Job]] = [:]
    
    // 콜백
    var onScheduleUpdated: (([Job]) -> Void)?
    var onDateSelected: ((Date) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onMonthChanged: ((Date) -> Void)?
    
    init() {
        selectedDate = Date()
    }
    
    // MARK: - 일정 관련 메서드
    
    // 특정 날짜의 일정 로드
    func loadSchedule(for date: Date) {
        selectedDate = date
        isLoading = true
        onLoadingStateChanged?(true)
        
        onDateSelected?(date)
        
        // 해당 월이 달라졌으면 달력 UI 업데이트
        checkAndUpdateMonth(for: date)
        
        // 서비스에서 일정 로드
        jobService.getTechnicianSchedule(
            date: date,
            onSuccess: { [weak self] loadedJobs in
                guard let self = self else { return }
                
                self.isLoading = false
                self.onLoadingStateChanged?(false)
                
                // 선택한 날짜에 해당하는 작업만 필터링
                let calendar = Calendar.current
                self.jobs = loadedJobs.filter { job in
                    guard let jobDate = job.startTime else { return false }
                    return calendar.isDate(jobDate, inSameDayAs: date)
                }
                
                // 해당 월의 작업 캐싱
                self.updateMonthJobs(jobs: loadedJobs)
                
                self.onScheduleUpdated?(self.jobs)
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                
                self.isLoading = false
                self.onLoadingStateChanged?(false)
                self.onError?(error)
            }
        )
    }
    
    // 해당 월의 작업 캐싱 업데이트
    private func updateMonthJobs(jobs: [Job]) {
        // 날짜별로 작업 그룹화
        for job in jobs {
            guard let startTime = job.startTime else { continue }
            
            // 날짜만 추출 (시간 제외)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: startTime)
            if let jobDate = calendar.date(from: components) {
                var jobsOnDate = monthJobs[jobDate] ?? []
                
                // 중복 방지
                if !jobsOnDate.contains(where: { $0.id == job.id }) {
                    jobsOnDate.append(job)
                }
                
                monthJobs[jobDate] = jobsOnDate
            }
        }
    }
    
    // 특정 날짜에 작업이 있는지 확인
    func hasJobs(on date: Date) -> Bool {
        // 날짜만 추출 (시간 제외)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let dateWithoutTime = calendar.date(from: components) {
            return (monthJobs[dateWithoutTime]?.isEmpty == false)
        }
        return false
    }
    
    // MARK: - 날짜 선택 관련 메서드
    
    // 이전 날짜 선택
    func selectPreviousDay() {
        guard let currentDate = selectedDate else { return }
        
        let calendar = Calendar.current
        if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
            selectDate(previousDay)
        }
    }
    
    // 다음 날짜 선택
    func selectNextDay() {
        guard let currentDate = selectedDate else { return }
        
        let calendar = Calendar.current
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
            selectDate(nextDay)
        }
    }
    
    // 날짜 선택
    func selectDate(_ date: Date) {
        selectedDate = date
        onDateSelected?(date)
        loadSchedule(for: date)
        
        // 해당 월이 달라졌으면 달력 UI 업데이트
        checkAndUpdateMonth(for: date)
    }
    
    // 특정 날짜가 현재 선택된 날짜인지 확인
    func isDateSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    // MARK: - 달력 관련 메서드
    
    // 현재 월 업데이트
    func updateCurrentMonth() {
        let today = Date()
        
        // 날짜에서 년/월만 추출
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: today)
        currentMonth = calendar.date(from: components)
        
        // 콜백 호출
        if let month = currentMonth {
            onMonthChanged?(month)
        }
    }
    
    // 날짜에 따라 월 업데이트 확인
    private func checkAndUpdateMonth(for date: Date) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let monthDate = calendar.date(from: dateComponents)
        
        // 현재 표시 중인 월과 다르면 업데이트
        if monthDate != currentMonth {
            currentMonth = monthDate
            
            // 콜백 호출
            if let month = currentMonth {
                onMonthChanged?(month)
            }
        }
    }
    
    // 이전 월 선택
    func selectPreviousMonth() {
        guard let currentMonth = currentMonth else { return }
        
        let calendar = Calendar.current
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            self.currentMonth = previousMonth
            onMonthChanged?(previousMonth)
        }
    }
    
    // 다음 월 선택
    func selectNextMonth() {
        guard let currentMonth = currentMonth else { return }
        
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            self.currentMonth = nextMonth
            onMonthChanged?(nextMonth)
        }
    }
    
    // 캘린더 그리드 데이터 가져오기 (6주 x 7일)
    func getCalendarData() -> [Date?]? {
        guard let currentMonth = currentMonth else { return nil }
        
        let calendar = Calendar.current
        
        // 월의 첫 날
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // 그리드의 시작일 (월의 첫 날이 속한 주의 일요일)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysToSubtract = firstWeekday - 1 // 일요일이 1
        let gridStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthStart)!
        
        // 월의 마지막 날
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        _ = calendar.date(byAdding: .day, value: -1, to: nextMonth)! // 현재 사용되지 않음
        
        // 그리드의 일수 (6주 * 7일)
        let totalDays = 42
        
        // 날짜 배열 생성
        var dates: [Date?] = []
        
        for day in 0..<totalDays {
            let date = calendar.date(byAdding: .day, value: day, to: gridStart)!
            
            // 현재 월에 속하는 날짜인지 확인
            if calendar.component(.month, from: date) == calendar.component(.month, from: currentMonth) {
                dates.append(date)
            } else {
                // 현재 월에 속하지 않는 날짜는 nil로 표시
                dates.append(nil)
            }
        }
        
        return dates
    }
    
    // 버튼 인덱스에 해당하는 날짜 가져오기
    func getDateForButton(at index: Int) -> Date? {
        return getCalendarData()?[index] ?? nil
    }
}
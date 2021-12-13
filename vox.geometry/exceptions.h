// Copyright (c) 2018 Doyub Kim
//
// I am making my contributions/submissions to this project solely in my
// personal capacity and am not conveying any rights to any intellectual
// property of any third parties.

#ifndef INCLUDE_JET_EXCEPTIONS_H_
#define INCLUDE_JET_EXCEPTIONS_H_

#include <exception>
#include <string>

namespace vox {

class NotImplementedException : public std::exception {
public:
  explicit NotImplementedException(std::string message);

  NotImplementedException(const NotImplementedException &other) noexcept;

  ~NotImplementedException() override;

  [[nodiscard]] const char *what() const noexcept override;

private:
  std::string _message;
};

} // namespace  vox

#endif // INCLUDE_JET_EXCEPTIONS_H_

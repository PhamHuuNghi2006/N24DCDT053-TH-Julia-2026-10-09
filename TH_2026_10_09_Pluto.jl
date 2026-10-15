### A Pluto.jl notebook ###
# v0.20.0

# ╔═╡ 09102026-0000-4000-8000-000000000001
begin
    READ_DATA = true
    RUN_APP = true
    ROOT_DATA = joinpath(@__DIR__, "data")
end

# ╔═╡ 09102026-0000-4000-8000-000000000002
AppCore = let
    sandbox = Module(:ThucHanhNgay0910)
    Base.include(sandbox, joinpath(@__DIR__, "TH_2026_10_09_Sinh_vien.jl"))
    Base.invokelatest(getfield, sandbox, :GiaoDon)
end

# ╔═╡ 09102026-0000-4000-8000-000000000003
"""MỤC TIÊU VÀ LUỒNG: chọn đơn giao trong ngân sách thời gian B = 8 để tổng lợi ích lớn nhất, rồi quản lý giao và hoàn tác. Luồng: CSV -> danh mục Order -> merge_sort (ID tăng) -> binary_search/BST -> bfs_routes (distance, parent, routes) -> costs[id] = 2h + phục vụ -> merge_sort (ưu tiên lợi ích/tau) -> knapsack -> danh sách kế hoạch + FIFO -> giao/hoàn tác (ngăn xếp) -> ket_qua.csv.

Ý TƯỞNG BỐN HÀM (giả mã ngắn):
NV1 merge_sort: nếu n <= 1 trả bản sao; chia đôi, sắp hai nửa bằng đệ quy; trộn bằng hai chỉ số, lấy nhánh phải chỉ khi before(phải, trái), hòa thì lấy trái (ổn định); chép phần dư. Chi phí O(n log n), bộ nhớ phụ O(n).
NV2 binary_search: dãy tăng theo id; lo=1, hi=n; trong khi lo <= hi lấy mid; bằng thì trả bản ghi, nhỏ hơn thì lo=mid+1, lớn hơn thì hi=mid-1; hết đoạn trả nothing. Chi phí O(log n), bộ nhớ O(1).
NV3 bfs_routes: FIFO; distance = -1, nguồn = 0; khi phát hiện v chưa tới thì đặt distance và parent ngay rồi mới đưa vào hàng đợi; dựng tuyến bằng cách lần parent về nguồn rồi đảo. Chỉ đúng cho đồ thị không trọng số. Chi phí O(V+E), bộ nhớ O(V) (lưu routes cho mọi đỉnh có thể O(V^2)).
NV4 knapsack: F(i,b) = F(i-1,b) nếu tau_i > b, ngược lại max(F(i-1,b), lợi ích_i + F(i-1, b - tau_i)); table[i+1,b+1] là F(i,b); truy vết từ (n,B). Chi phí O(nB) thời gian và bộ nhớ.

Điều kiện áp dụng: ID đơn duy nhất; bản đồ vô hướng, mỗi cạnh một đơn vị thời gian; tau và B là số nguyên."""

# ╔═╡ 09102026-0000-4000-8000-000000000004
ho_so = AppCore.mini_profile()

# ╔═╡ 09102026-0000-4000-8000-000000000005
du_lieu = READ_DATA ? AppCore.read_data(joinpath(ROOT_DATA,"MINI001")) : nothing

# ╔═╡ 09102026-0000-4000-8000-000000000006
bao_cao = !RUN_APP || du_lieu === nothing ? nothing : let
    s = AppCore.build_session(du_lieu.orders,du_lieu.edges,ho_so)
    r = AppCore.plan!(s)
    trace = NamedTuple[]
    save(label) = push!(trace,(buoc=label,queue=AppCore.queue_values(s.pending),
                              stack=copy(s.completed),spent=s.spent,earned=s.earned))
    save("Sau lập kế hoạch")
    AppCore.deliver!(s); save("Sau giao một đơn")
    AppCore.undo!(s); save("Sau hoàn tác")
    while s.pending.count > 0
        AppCore.deliver!(s)
    end
    save("Sau giao hết")
    (chi_phi=copy(s.costs),tuyen=deepcopy(s.routes),chon=copy(s.selected_ids),
     loi_ich_toi_uu=r.optimal.value,truy_vet=trace,bat_bien=AppCore.check_invariants(s))
end

# ╔═╡ 09102026-0000-4000-8000-000000000007
"""Ô F(2,8) = max(F(1,8), 8 + F(1,3)) = max(6, 8 + 6) = 14, nằm ở table[3,9] trong Julia vì table[i+1,b+1] biểu diễn F(i,b). Nhánh lấy đơn phải dùng hàng i-1 để mỗi đơn chỉ được chọn một lần; dùng lại hàng i sẽ cho phép lấy một đơn nhiều lần. Kết quả DP trên bộ MINI001 là 14 và bằng giá trị vét cạn (8 tập con), tập chọn là ID 1 và 2 với tổng thời gian 8."""

# ╔═╡ 09102026-0000-4000-8000-000000000008
"""MINH CHỨNG NỘP: bốn hàm nằm trong TH_2026_10_09_Sinh_vien.jl; kiểm thử bằng julia TH_2026_10_09_Kiem_thu.jl --phase=sort|search|bfs|dp|app|all; CSV kết quả: data/MINI001/ket_qua.csv. GitHub: https://github.com/PhamHuuNghi2006/N24DCDT053-TH-Julia-2026-10-09 . Commit SHA ghi theo phiếu thực hành (lấy bằng git rev-parse HEAD ở lần push cuối)."""

# ╔═╡ 09102026-0000-4000-8000-000000000009
if RUN_APP && bao_cao !== nothing
    println("Kết quả từ cùng lõi ứng dụng Julia:")
    show(stdout, "text/plain", bao_cao)
    println()
end

# ╔═╡ Cell order:
# ╠═09102026-0000-4000-8000-000000000001
# ╠═09102026-0000-4000-8000-000000000002
# ╠═09102026-0000-4000-8000-000000000003
# ╠═09102026-0000-4000-8000-000000000004
# ╠═09102026-0000-4000-8000-000000000005
# ╠═09102026-0000-4000-8000-000000000006
# ╠═09102026-0000-4000-8000-000000000007
# ╠═09102026-0000-4000-8000-000000000008
# ╠═09102026-0000-4000-8000-000000000009

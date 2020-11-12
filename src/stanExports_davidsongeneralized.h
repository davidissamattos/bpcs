// Generated by rstantools.  Do not edit by hand.

/*
    bpc is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    bpc is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with bpc.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef MODELS_HPP
#define MODELS_HPP
#define STAN__SERVICES__COMMAND_HPP
#include <rstan/rstaninc.hpp>
// Code generated by Stan version 2.21.0
#include <stan/model/model_header.hpp>
namespace model_davidsongeneralized_namespace {
using std::istream;
using std::string;
using std::stringstream;
using std::vector;
using stan::io::dump;
using stan::math::lgamma;
using stan::model::prob_grad;
using namespace stan::math;
static int current_statement_begin__;
stan::io::program_reader prog_reader__() {
    stan::io::program_reader reader;
    reader.add_event(0, 0, "start", "model_davidsongeneralized");
    reader.add_event(111, 109, "end", "model_davidsongeneralized");
    return reader;
}
#include <stan_meta_header.hpp>
class model_davidsongeneralized
  : public stan::model::model_base_crtp<model_davidsongeneralized> {
private:
        int N_total;
        std::vector<int> y;
        int N_players;
        std::vector<int> player0_indexes;
        std::vector<int> player1_indexes;
        std::vector<int> ties;
        int K;
        matrix_d X;
        double prior_lambda_std;
        double prior_lambda_mu;
        double prior_nu_mu;
        double prior_nu_std;
public:
    model_davidsongeneralized(stan::io::var_context& context__,
        std::ostream* pstream__ = 0)
        : model_base_crtp(0) {
        ctor_body(context__, 0, pstream__);
    }
    model_davidsongeneralized(stan::io::var_context& context__,
        unsigned int random_seed__,
        std::ostream* pstream__ = 0)
        : model_base_crtp(0) {
        ctor_body(context__, random_seed__, pstream__);
    }
    void ctor_body(stan::io::var_context& context__,
                   unsigned int random_seed__,
                   std::ostream* pstream__) {
        typedef double local_scalar_t__;
        boost::ecuyer1988 base_rng__ =
          stan::services::util::create_rng(random_seed__, 0);
        (void) base_rng__;  // suppress unused var warning
        current_statement_begin__ = -1;
        static const char* function__ = "model_davidsongeneralized_namespace::model_davidsongeneralized";
        (void) function__;  // dummy to suppress unused var warning
        size_t pos__;
        (void) pos__;  // dummy to suppress unused var warning
        std::vector<int> vals_i__;
        std::vector<double> vals_r__;
        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // suppress unused var warning
        try {
            // initialize data block variables from context__
            current_statement_begin__ = 7;
            context__.validate_dims("data initialization", "N_total", "int", context__.to_vec());
            N_total = int(0);
            vals_i__ = context__.vals_i("N_total");
            pos__ = 0;
            N_total = vals_i__[pos__++];
            check_greater_or_equal(function__, "N_total", N_total, 1);
            current_statement_begin__ = 8;
            validate_non_negative_index("y", "N_total", N_total);
            context__.validate_dims("data initialization", "y", "int", context__.to_vec(N_total));
            y = std::vector<int>(N_total, int(0));
            vals_i__ = context__.vals_i("y");
            pos__ = 0;
            size_t y_k_0_max__ = N_total;
            for (size_t k_0__ = 0; k_0__ < y_k_0_max__; ++k_0__) {
                y[k_0__] = vals_i__[pos__++];
            }
            size_t y_i_0_max__ = N_total;
            for (size_t i_0__ = 0; i_0__ < y_i_0_max__; ++i_0__) {
                check_greater_or_equal(function__, "y[i_0__]", y[i_0__], 0);
                check_less_or_equal(function__, "y[i_0__]", y[i_0__], 2);
            }
            current_statement_begin__ = 9;
            context__.validate_dims("data initialization", "N_players", "int", context__.to_vec());
            N_players = int(0);
            vals_i__ = context__.vals_i("N_players");
            pos__ = 0;
            N_players = vals_i__[pos__++];
            check_greater_or_equal(function__, "N_players", N_players, 1);
            current_statement_begin__ = 10;
            validate_non_negative_index("player0_indexes", "N_total", N_total);
            context__.validate_dims("data initialization", "player0_indexes", "int", context__.to_vec(N_total));
            player0_indexes = std::vector<int>(N_total, int(0));
            vals_i__ = context__.vals_i("player0_indexes");
            pos__ = 0;
            size_t player0_indexes_k_0_max__ = N_total;
            for (size_t k_0__ = 0; k_0__ < player0_indexes_k_0_max__; ++k_0__) {
                player0_indexes[k_0__] = vals_i__[pos__++];
            }
            size_t player0_indexes_i_0_max__ = N_total;
            for (size_t i_0__ = 0; i_0__ < player0_indexes_i_0_max__; ++i_0__) {
                check_greater_or_equal(function__, "player0_indexes[i_0__]", player0_indexes[i_0__], 1);
            }
            current_statement_begin__ = 11;
            validate_non_negative_index("player1_indexes", "N_total", N_total);
            context__.validate_dims("data initialization", "player1_indexes", "int", context__.to_vec(N_total));
            player1_indexes = std::vector<int>(N_total, int(0));
            vals_i__ = context__.vals_i("player1_indexes");
            pos__ = 0;
            size_t player1_indexes_k_0_max__ = N_total;
            for (size_t k_0__ = 0; k_0__ < player1_indexes_k_0_max__; ++k_0__) {
                player1_indexes[k_0__] = vals_i__[pos__++];
            }
            size_t player1_indexes_i_0_max__ = N_total;
            for (size_t i_0__ = 0; i_0__ < player1_indexes_i_0_max__; ++i_0__) {
                check_greater_or_equal(function__, "player1_indexes[i_0__]", player1_indexes[i_0__], 1);
            }
            current_statement_begin__ = 12;
            validate_non_negative_index("ties", "N_total", N_total);
            context__.validate_dims("data initialization", "ties", "int", context__.to_vec(N_total));
            ties = std::vector<int>(N_total, int(0));
            vals_i__ = context__.vals_i("ties");
            pos__ = 0;
            size_t ties_k_0_max__ = N_total;
            for (size_t k_0__ = 0; k_0__ < ties_k_0_max__; ++k_0__) {
                ties[k_0__] = vals_i__[pos__++];
            }
            size_t ties_i_0_max__ = N_total;
            for (size_t i_0__ = 0; i_0__ < ties_i_0_max__; ++i_0__) {
                check_greater_or_equal(function__, "ties[i_0__]", ties[i_0__], 0);
                check_less_or_equal(function__, "ties[i_0__]", ties[i_0__], 1);
            }
            current_statement_begin__ = 13;
            context__.validate_dims("data initialization", "K", "int", context__.to_vec());
            K = int(0);
            vals_i__ = context__.vals_i("K");
            pos__ = 0;
            K = vals_i__[pos__++];
            check_greater_or_equal(function__, "K", K, 1);
            current_statement_begin__ = 14;
            validate_non_negative_index("X", "N_players", N_players);
            validate_non_negative_index("X", "K", K);
            context__.validate_dims("data initialization", "X", "matrix_d", context__.to_vec(N_players,K));
            X = Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>(N_players, K);
            vals_r__ = context__.vals_r("X");
            pos__ = 0;
            size_t X_j_2_max__ = K;
            size_t X_j_1_max__ = N_players;
            for (size_t j_2__ = 0; j_2__ < X_j_2_max__; ++j_2__) {
                for (size_t j_1__ = 0; j_1__ < X_j_1_max__; ++j_1__) {
                    X(j_1__, j_2__) = vals_r__[pos__++];
                }
            }
            current_statement_begin__ = 15;
            context__.validate_dims("data initialization", "prior_lambda_std", "double", context__.to_vec());
            prior_lambda_std = double(0);
            vals_r__ = context__.vals_r("prior_lambda_std");
            pos__ = 0;
            prior_lambda_std = vals_r__[pos__++];
            check_greater_or_equal(function__, "prior_lambda_std", prior_lambda_std, 0);
            current_statement_begin__ = 16;
            context__.validate_dims("data initialization", "prior_lambda_mu", "double", context__.to_vec());
            prior_lambda_mu = double(0);
            vals_r__ = context__.vals_r("prior_lambda_mu");
            pos__ = 0;
            prior_lambda_mu = vals_r__[pos__++];
            current_statement_begin__ = 17;
            context__.validate_dims("data initialization", "prior_nu_mu", "double", context__.to_vec());
            prior_nu_mu = double(0);
            vals_r__ = context__.vals_r("prior_nu_mu");
            pos__ = 0;
            prior_nu_mu = vals_r__[pos__++];
            current_statement_begin__ = 18;
            context__.validate_dims("data initialization", "prior_nu_std", "double", context__.to_vec());
            prior_nu_std = double(0);
            vals_r__ = context__.vals_r("prior_nu_std");
            pos__ = 0;
            prior_nu_std = vals_r__[pos__++];
            check_greater_or_equal(function__, "prior_nu_std", prior_nu_std, 0);
            // initialize transformed data variables
            // execute transformed data statements
            // validate transformed data
            // validate, set parameter ranges
            num_params_r__ = 0U;
            param_ranges_i__.clear();
            current_statement_begin__ = 22;
            validate_non_negative_index("B", "K", K);
            num_params_r__ += K;
            current_statement_begin__ = 23;
            num_params_r__ += 1;
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }
    }
    ~model_davidsongeneralized() { }
    void transform_inits(const stan::io::var_context& context__,
                         std::vector<int>& params_i__,
                         std::vector<double>& params_r__,
                         std::ostream* pstream__) const {
        typedef double local_scalar_t__;
        stan::io::writer<double> writer__(params_r__, params_i__);
        size_t pos__;
        (void) pos__; // dummy call to supress warning
        std::vector<double> vals_r__;
        std::vector<int> vals_i__;
        current_statement_begin__ = 22;
        if (!(context__.contains_r("B")))
            stan::lang::rethrow_located(std::runtime_error(std::string("Variable B missing")), current_statement_begin__, prog_reader__());
        vals_r__ = context__.vals_r("B");
        pos__ = 0U;
        validate_non_negative_index("B", "K", K);
        context__.validate_dims("parameter initialization", "B", "vector_d", context__.to_vec(K));
        Eigen::Matrix<double, Eigen::Dynamic, 1> B(K);
        size_t B_j_1_max__ = K;
        for (size_t j_1__ = 0; j_1__ < B_j_1_max__; ++j_1__) {
            B(j_1__) = vals_r__[pos__++];
        }
        try {
            writer__.vector_unconstrain(B);
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(std::runtime_error(std::string("Error transforming variable B: ") + e.what()), current_statement_begin__, prog_reader__());
        }
        current_statement_begin__ = 23;
        if (!(context__.contains_r("nu")))
            stan::lang::rethrow_located(std::runtime_error(std::string("Variable nu missing")), current_statement_begin__, prog_reader__());
        vals_r__ = context__.vals_r("nu");
        pos__ = 0U;
        context__.validate_dims("parameter initialization", "nu", "double", context__.to_vec());
        double nu(0);
        nu = vals_r__[pos__++];
        try {
            writer__.scalar_unconstrain(nu);
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(std::runtime_error(std::string("Error transforming variable nu: ") + e.what()), current_statement_begin__, prog_reader__());
        }
        params_r__ = writer__.data_r();
        params_i__ = writer__.data_i();
    }
    void transform_inits(const stan::io::var_context& context,
                         Eigen::Matrix<double, Eigen::Dynamic, 1>& params_r,
                         std::ostream* pstream__) const {
      std::vector<double> params_r_vec;
      std::vector<int> params_i_vec;
      transform_inits(context, params_i_vec, params_r_vec, pstream__);
      params_r.resize(params_r_vec.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r(i) = params_r_vec[i];
    }
    template <bool propto__, bool jacobian__, typename T__>
    T__ log_prob(std::vector<T__>& params_r__,
                 std::vector<int>& params_i__,
                 std::ostream* pstream__ = 0) const {
        typedef T__ local_scalar_t__;
        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // dummy to suppress unused var warning
        T__ lp__(0.0);
        stan::math::accumulator<T__> lp_accum__;
        try {
            stan::io::reader<local_scalar_t__> in__(params_r__, params_i__);
            // model parameters
            current_statement_begin__ = 22;
            Eigen::Matrix<local_scalar_t__, Eigen::Dynamic, 1> B;
            (void) B;  // dummy to suppress unused var warning
            if (jacobian__)
                B = in__.vector_constrain(K, lp__);
            else
                B = in__.vector_constrain(K);
            current_statement_begin__ = 23;
            local_scalar_t__ nu;
            (void) nu;  // dummy to suppress unused var warning
            if (jacobian__)
                nu = in__.scalar_constrain(lp__);
            else
                nu = in__.scalar_constrain();
            // model body
            current_statement_begin__ = 30;
            lp_accum__.add(normal_log<propto__>(B, prior_lambda_mu, prior_lambda_std));
            current_statement_begin__ = 31;
            lp_accum__.add(normal_log<propto__>(nu, prior_nu_mu, prior_nu_std));
            current_statement_begin__ = 34;
            for (int i = 1; i <= N_total; ++i) {
                {
                current_statement_begin__ = 37;
                local_scalar_t__ lambda0(DUMMY_VAR__);
                (void) lambda0;  // dummy to suppress unused var warning
                stan::math::initialize(lambda0, DUMMY_VAR__);
                stan::math::fill(lambda0, DUMMY_VAR__);
                current_statement_begin__ = 38;
                local_scalar_t__ lambda1(DUMMY_VAR__);
                (void) lambda1;  // dummy to suppress unused var warning
                stan::math::initialize(lambda1, DUMMY_VAR__);
                stan::math::fill(lambda1, DUMMY_VAR__);
                current_statement_begin__ = 39;
                validate_non_negative_index("X0", "K", K);
                Eigen::Matrix<local_scalar_t__, Eigen::Dynamic, 1> X0(K);
                stan::math::initialize(X0, DUMMY_VAR__);
                stan::math::fill(X0, DUMMY_VAR__);
                current_statement_begin__ = 40;
                validate_non_negative_index("X1", "K", K);
                Eigen::Matrix<local_scalar_t__, Eigen::Dynamic, 1> X1(K);
                stan::math::initialize(X1, DUMMY_VAR__);
                stan::math::fill(X1, DUMMY_VAR__);
                current_statement_begin__ = 41;
                local_scalar_t__ p1_win(DUMMY_VAR__);
                (void) p1_win;  // dummy to suppress unused var warning
                stan::math::initialize(p1_win, DUMMY_VAR__);
                stan::math::fill(p1_win, DUMMY_VAR__);
                current_statement_begin__ = 42;
                local_scalar_t__ p1(DUMMY_VAR__);
                (void) p1;  // dummy to suppress unused var warning
                stan::math::initialize(p1, DUMMY_VAR__);
                stan::math::fill(p1, DUMMY_VAR__);
                current_statement_begin__ = 43;
                local_scalar_t__ p0(DUMMY_VAR__);
                (void) p0;  // dummy to suppress unused var warning
                stan::math::initialize(p0, DUMMY_VAR__);
                stan::math::fill(p0, DUMMY_VAR__);
                current_statement_begin__ = 44;
                local_scalar_t__ geom_term(DUMMY_VAR__);
                (void) geom_term;  // dummy to suppress unused var warning
                stan::math::initialize(geom_term, DUMMY_VAR__);
                stan::math::fill(geom_term, DUMMY_VAR__);
                current_statement_begin__ = 45;
                local_scalar_t__ p_draw(DUMMY_VAR__);
                (void) p_draw;  // dummy to suppress unused var warning
                stan::math::initialize(p_draw, DUMMY_VAR__);
                stan::math::fill(p_draw, DUMMY_VAR__);
                current_statement_begin__ = 46;
                local_scalar_t__ p_1_win_not_draw(DUMMY_VAR__);
                (void) p_1_win_not_draw;  // dummy to suppress unused var warning
                stan::math::initialize(p_1_win_not_draw, DUMMY_VAR__);
                stan::math::fill(p_1_win_not_draw, DUMMY_VAR__);
                current_statement_begin__ = 49;
                stan::math::assign(X0, to_vector(stan::model::rvalue(X, stan::model::cons_list(stan::model::index_uni(get_base1(player0_indexes, i, "player0_indexes", 1)), stan::model::cons_list(stan::model::index_omni(), stan::model::nil_index_list())), "X")));
                current_statement_begin__ = 50;
                stan::math::assign(X1, to_vector(stan::model::rvalue(X, stan::model::cons_list(stan::model::index_uni(get_base1(player1_indexes, i, "player1_indexes", 1)), stan::model::cons_list(stan::model::index_omni(), stan::model::nil_index_list())), "X")));
                current_statement_begin__ = 51;
                stan::math::assign(lambda0, dot_product(X0, B));
                current_statement_begin__ = 52;
                stan::math::assign(lambda1, dot_product(X1, B));
                current_statement_begin__ = 54;
                stan::math::assign(p0, stan::math::exp(lambda0));
                current_statement_begin__ = 55;
                stan::math::assign(p1, stan::math::exp(lambda1));
                current_statement_begin__ = 56;
                stan::math::assign(geom_term, stan::math::exp((nu + (0.5 * (lambda0 + lambda1)))));
                current_statement_begin__ = 58;
                stan::math::assign(p_draw, (geom_term / ((p0 + p1) + geom_term)));
                current_statement_begin__ = 59;
                stan::math::assign(p_1_win_not_draw, (p1 / ((p0 + p1) + geom_term)));
                current_statement_begin__ = 62;
                if (as_bool(logical_eq(get_base1(ties, i, "ties", 1), 1))) {
                    current_statement_begin__ = 62;
                    lp_accum__.add(bernoulli_log(get_base1(ties, i, "ties", 1), p_draw));
                }
                current_statement_begin__ = 64;
                if (as_bool(logical_eq(get_base1(ties, i, "ties", 1), 0))) {
                    current_statement_begin__ = 64;
                    lp_accum__.add(bernoulli_log(get_base1(y, i, "y", 1), p_1_win_not_draw));
                }
                }
            }
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }
        lp_accum__.add(lp__);
        return lp_accum__.sum();
    } // log_prob()
    template <bool propto, bool jacobian, typename T_>
    T_ log_prob(Eigen::Matrix<T_,Eigen::Dynamic,1>& params_r,
               std::ostream* pstream = 0) const {
      std::vector<T_> vec_params_r;
      vec_params_r.reserve(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        vec_params_r.push_back(params_r(i));
      std::vector<int> vec_params_i;
      return log_prob<propto,jacobian,T_>(vec_params_r, vec_params_i, pstream);
    }
    void get_param_names(std::vector<std::string>& names__) const {
        names__.resize(0);
        names__.push_back("B");
        names__.push_back("nu");
        names__.push_back("log_lik");
        names__.push_back("lambda");
    }
    void get_dims(std::vector<std::vector<size_t> >& dimss__) const {
        dimss__.resize(0);
        std::vector<size_t> dims__;
        dims__.resize(0);
        dims__.push_back(K);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dims__.push_back(N_total);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dims__.push_back(N_players);
        dimss__.push_back(dims__);
    }
    template <typename RNG>
    void write_array(RNG& base_rng__,
                     std::vector<double>& params_r__,
                     std::vector<int>& params_i__,
                     std::vector<double>& vars__,
                     bool include_tparams__ = true,
                     bool include_gqs__ = true,
                     std::ostream* pstream__ = 0) const {
        typedef double local_scalar_t__;
        vars__.resize(0);
        stan::io::reader<local_scalar_t__> in__(params_r__, params_i__);
        static const char* function__ = "model_davidsongeneralized_namespace::write_array";
        (void) function__;  // dummy to suppress unused var warning
        // read-transform, write parameters
        Eigen::Matrix<double, Eigen::Dynamic, 1> B = in__.vector_constrain(K);
        size_t B_j_1_max__ = K;
        for (size_t j_1__ = 0; j_1__ < B_j_1_max__; ++j_1__) {
            vars__.push_back(B(j_1__));
        }
        double nu = in__.scalar_constrain();
        vars__.push_back(nu);
        double lp__ = 0.0;
        (void) lp__;  // dummy to suppress unused var warning
        stan::math::accumulator<double> lp_accum__;
        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // suppress unused var warning
        if (!include_tparams__ && !include_gqs__) return;
        try {
            if (!include_gqs__ && !include_tparams__) return;
            if (!include_gqs__) return;
            // declare and define generated quantities
            current_statement_begin__ = 71;
            validate_non_negative_index("log_lik", "N_total", N_total);
            Eigen::Matrix<double, Eigen::Dynamic, 1> log_lik(N_total);
            stan::math::initialize(log_lik, DUMMY_VAR__);
            stan::math::fill(log_lik, DUMMY_VAR__);
            current_statement_begin__ = 72;
            validate_non_negative_index("lambda", "N_players", N_players);
            Eigen::Matrix<double, Eigen::Dynamic, 1> lambda(N_players);
            stan::math::initialize(lambda, DUMMY_VAR__);
            stan::math::fill(lambda, DUMMY_VAR__);
            // generated quantities statements
            current_statement_begin__ = 73;
            for (int i = 1; i <= N_total; ++i) {
                {
                current_statement_begin__ = 76;
                local_scalar_t__ lambda0(DUMMY_VAR__);
                (void) lambda0;  // dummy to suppress unused var warning
                stan::math::initialize(lambda0, DUMMY_VAR__);
                stan::math::fill(lambda0, DUMMY_VAR__);
                current_statement_begin__ = 77;
                local_scalar_t__ lambda1(DUMMY_VAR__);
                (void) lambda1;  // dummy to suppress unused var warning
                stan::math::initialize(lambda1, DUMMY_VAR__);
                stan::math::fill(lambda1, DUMMY_VAR__);
                current_statement_begin__ = 78;
                validate_non_negative_index("X0", "K", K);
                Eigen::Matrix<local_scalar_t__, Eigen::Dynamic, 1> X0(K);
                stan::math::initialize(X0, DUMMY_VAR__);
                stan::math::fill(X0, DUMMY_VAR__);
                current_statement_begin__ = 79;
                validate_non_negative_index("X1", "K", K);
                Eigen::Matrix<local_scalar_t__, Eigen::Dynamic, 1> X1(K);
                stan::math::initialize(X1, DUMMY_VAR__);
                stan::math::fill(X1, DUMMY_VAR__);
                current_statement_begin__ = 80;
                local_scalar_t__ p1_win(DUMMY_VAR__);
                (void) p1_win;  // dummy to suppress unused var warning
                stan::math::initialize(p1_win, DUMMY_VAR__);
                stan::math::fill(p1_win, DUMMY_VAR__);
                current_statement_begin__ = 81;
                local_scalar_t__ p1(DUMMY_VAR__);
                (void) p1;  // dummy to suppress unused var warning
                stan::math::initialize(p1, DUMMY_VAR__);
                stan::math::fill(p1, DUMMY_VAR__);
                current_statement_begin__ = 82;
                local_scalar_t__ p0(DUMMY_VAR__);
                (void) p0;  // dummy to suppress unused var warning
                stan::math::initialize(p0, DUMMY_VAR__);
                stan::math::fill(p0, DUMMY_VAR__);
                current_statement_begin__ = 83;
                local_scalar_t__ geom_term(DUMMY_VAR__);
                (void) geom_term;  // dummy to suppress unused var warning
                stan::math::initialize(geom_term, DUMMY_VAR__);
                stan::math::fill(geom_term, DUMMY_VAR__);
                current_statement_begin__ = 84;
                local_scalar_t__ p_draw(DUMMY_VAR__);
                (void) p_draw;  // dummy to suppress unused var warning
                stan::math::initialize(p_draw, DUMMY_VAR__);
                stan::math::fill(p_draw, DUMMY_VAR__);
                current_statement_begin__ = 85;
                local_scalar_t__ p_1_win_not_draw(DUMMY_VAR__);
                (void) p_1_win_not_draw;  // dummy to suppress unused var warning
                stan::math::initialize(p_1_win_not_draw, DUMMY_VAR__);
                stan::math::fill(p_1_win_not_draw, DUMMY_VAR__);
                current_statement_begin__ = 88;
                stan::math::assign(X0, to_vector(stan::model::rvalue(X, stan::model::cons_list(stan::model::index_uni(get_base1(player0_indexes, i, "player0_indexes", 1)), stan::model::cons_list(stan::model::index_omni(), stan::model::nil_index_list())), "X")));
                current_statement_begin__ = 89;
                stan::math::assign(X1, to_vector(stan::model::rvalue(X, stan::model::cons_list(stan::model::index_uni(get_base1(player1_indexes, i, "player1_indexes", 1)), stan::model::cons_list(stan::model::index_omni(), stan::model::nil_index_list())), "X")));
                current_statement_begin__ = 90;
                stan::math::assign(lambda0, dot_product(X0, B));
                current_statement_begin__ = 91;
                stan::math::assign(lambda1, dot_product(X1, B));
                current_statement_begin__ = 93;
                stan::math::assign(p0, stan::math::exp(lambda0));
                current_statement_begin__ = 94;
                stan::math::assign(p1, stan::math::exp(lambda1));
                current_statement_begin__ = 95;
                stan::math::assign(geom_term, stan::math::exp((nu + (0.5 * (lambda0 + lambda1)))));
                current_statement_begin__ = 97;
                stan::math::assign(p_draw, (geom_term / ((p0 + p1) + geom_term)));
                current_statement_begin__ = 98;
                stan::math::assign(p_1_win_not_draw, (p1 / ((p0 + p1) + geom_term)));
                current_statement_begin__ = 100;
                if (as_bool(logical_eq(get_base1(ties, i, "ties", 1), 1))) {
                    current_statement_begin__ = 100;
                    stan::model::assign(log_lik, 
                                stan::model::cons_list(stan::model::index_uni(i), stan::model::nil_index_list()), 
                                bernoulli_log(get_base1(ties, i, "ties", 1), p_draw), 
                                "assigning variable log_lik");
                }
                current_statement_begin__ = 102;
                if (as_bool(logical_eq(get_base1(ties, i, "ties", 1), 0))) {
                    current_statement_begin__ = 102;
                    stan::model::assign(log_lik, 
                                stan::model::cons_list(stan::model::index_uni(i), stan::model::nil_index_list()), 
                                bernoulli_log(get_base1(y, i, "y", 1), p_1_win_not_draw), 
                                "assigning variable log_lik");
                }
                }
            }
            current_statement_begin__ = 106;
            for (int i = 1; i <= N_players; ++i) {
                current_statement_begin__ = 107;
                stan::model::assign(lambda, 
                            stan::model::cons_list(stan::model::index_uni(i), stan::model::nil_index_list()), 
                            dot_product(B, to_vector(stan::model::rvalue(X, stan::model::cons_list(stan::model::index_uni(i), stan::model::cons_list(stan::model::index_omni(), stan::model::nil_index_list())), "X"))), 
                            "assigning variable lambda");
            }
            // validate, write generated quantities
            current_statement_begin__ = 71;
            size_t log_lik_j_1_max__ = N_total;
            for (size_t j_1__ = 0; j_1__ < log_lik_j_1_max__; ++j_1__) {
                vars__.push_back(log_lik(j_1__));
            }
            current_statement_begin__ = 72;
            size_t lambda_j_1_max__ = N_players;
            for (size_t j_1__ = 0; j_1__ < lambda_j_1_max__; ++j_1__) {
                vars__.push_back(lambda(j_1__));
            }
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }
    }
    template <typename RNG>
    void write_array(RNG& base_rng,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& params_r,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& vars,
                     bool include_tparams = true,
                     bool include_gqs = true,
                     std::ostream* pstream = 0) const {
      std::vector<double> params_r_vec(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r_vec[i] = params_r(i);
      std::vector<double> vars_vec;
      std::vector<int> params_i_vec;
      write_array(base_rng, params_r_vec, params_i_vec, vars_vec, include_tparams, include_gqs, pstream);
      vars.resize(vars_vec.size());
      for (int i = 0; i < vars.size(); ++i)
        vars(i) = vars_vec[i];
    }
    std::string model_name() const {
        return "model_davidsongeneralized";
    }
    void constrained_param_names(std::vector<std::string>& param_names__,
                                 bool include_tparams__ = true,
                                 bool include_gqs__ = true) const {
        std::stringstream param_name_stream__;
        size_t B_j_1_max__ = K;
        for (size_t j_1__ = 0; j_1__ < B_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "B" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
        param_name_stream__.str(std::string());
        param_name_stream__ << "nu";
        param_names__.push_back(param_name_stream__.str());
        if (!include_gqs__ && !include_tparams__) return;
        if (include_tparams__) {
        }
        if (!include_gqs__) return;
        size_t log_lik_j_1_max__ = N_total;
        for (size_t j_1__ = 0; j_1__ < log_lik_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "log_lik" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
        size_t lambda_j_1_max__ = N_players;
        for (size_t j_1__ = 0; j_1__ < lambda_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "lambda" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
    }
    void unconstrained_param_names(std::vector<std::string>& param_names__,
                                   bool include_tparams__ = true,
                                   bool include_gqs__ = true) const {
        std::stringstream param_name_stream__;
        size_t B_j_1_max__ = K;
        for (size_t j_1__ = 0; j_1__ < B_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "B" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
        param_name_stream__.str(std::string());
        param_name_stream__ << "nu";
        param_names__.push_back(param_name_stream__.str());
        if (!include_gqs__ && !include_tparams__) return;
        if (include_tparams__) {
        }
        if (!include_gqs__) return;
        size_t log_lik_j_1_max__ = N_total;
        for (size_t j_1__ = 0; j_1__ < log_lik_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "log_lik" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
        size_t lambda_j_1_max__ = N_players;
        for (size_t j_1__ = 0; j_1__ < lambda_j_1_max__; ++j_1__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "lambda" << '.' << j_1__ + 1;
            param_names__.push_back(param_name_stream__.str());
        }
    }
}; // model
}  // namespace
typedef model_davidsongeneralized_namespace::model_davidsongeneralized stan_model;
#ifndef USING_R
stan::model::model_base& new_model(
        stan::io::var_context& data_context,
        unsigned int seed,
        std::ostream* msg_stream) {
  stan_model* m = new stan_model(data_context, seed, msg_stream);
  return *m;
}
#endif
#endif